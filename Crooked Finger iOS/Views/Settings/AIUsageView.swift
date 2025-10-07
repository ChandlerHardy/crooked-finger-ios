//
//  AIUsageView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/4/25.
//

import SwiftUI
import Combine

struct AIUsageView: View {
    @State private var viewModel = AIUsageViewModel()
    @State private var timeUntilReset = "--h --m --s"
    @State private var showModelPicker = false
    @State private var availableModels: [String] = []
    @State private var selectedModel: String? = nil
    @State private var currentProvider = "auto"
    @State private var modelPriorityOrder: [String] = []

    private var currentModeDescription: String {
        if let model = selectedModel {
            return "Single Model: \(modelDisplayName(model))"
        } else if modelPriorityOrder.isEmpty {
            return "Smart Routing (Complexity-Based)"
        } else {
            return "Fallback Chain (\(modelPriorityOrder.count) models)"
        }
    }

    // Timer for countdown
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchUsage()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.primaryBrown)
                    }
                    .padding()
                } else if let dashboard = viewModel.dashboard {
                    // Model Selection Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Model Configuration")
                                    .font(.headline)
                                    .foregroundStyle(Color.appText)
                                Text(currentModeDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appMuted)
                            }

                            Spacer()

                            Button("Configure") {
                                showModelPicker = true
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.primaryBrown)
                        }
                    }
                    .padding()
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)

                    // Summary Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Requests Today")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(dashboard.totalRequestsToday)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.primaryBrown)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Remaining")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(dashboard.totalRemaining)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                            }
                        }

                        Divider()

                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(Color.primaryBrown)
                            Text("Quota resets in:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(timeUntilReset)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appText)
                        }
                    }
                    .padding()
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)

                    // Models List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Models")
                            .font(.headline)
                            .foregroundStyle(Color.appText)
                            .padding(.horizontal)

                        ForEach(dashboard.models) { model in
                            ModelUsageCard(model: model)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No usage data available")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("AI Usage")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.fetchUsage()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Color.primaryBrown)
                }
                .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUsage()
            }
        }
        .onReceive(timer) { _ in
            timeUntilReset = viewModel.timeUntilReset()
        }
        .sheet(isPresented: $showModelPicker) {
            ModelPickerSheet(
                availableModels: availableModels,
                selectedModel: $selectedModel,
                currentPriorityOrder: modelPriorityOrder,
                onSave: {
                    Task {
                        await fetchModelConfig()
                    }
                }
            )
        }
        .task {
            await fetchModelConfig()
        }
    }

    private func fetchModelConfig() async {
        // Fetch available models and current selection from backend
        let query = """
        query {
            aiProviderConfig {
                selectedModel
                availableModels
                currentProvider
                modelPriorityOrder
            }
        }
        """

        guard let url = URL(string: APIConfig.currentGraphqlURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = ["query": query]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let data = json["data"] as? [String: Any],
               let config = data["aiProviderConfig"] as? [String: Any] {
                await MainActor.run {
                    availableModels = config["availableModels"] as? [String] ?? []
                    selectedModel = config["selectedModel"] as? String
                    currentProvider = config["currentProvider"] as? String ?? "auto"
                    modelPriorityOrder = config["modelPriorityOrder"] as? [String] ?? []
                }
            }
        } catch {
            print("Failed to fetch model config: \(error)")
        }
    }

    private func modelDisplayName(_ model: String) -> String {
        if model.contains("deepseek") {
            return "DeepSeek Chat v3.1"
        } else if model.contains("qwen") {
            return "Qwen3 30B A3B"
        } else if model.contains("gemini-2.5-pro") {
            return "Gemini 2.5 Pro"
        } else if model.contains("flash-preview") {
            return "Gemini 2.5 Flash Preview"
        } else if model.contains("flash-lite") {
            return "Gemini 2.5 Flash Lite"
        } else if model.contains("flash") {
            return "Gemini 2.5 Flash"
        }
        return model
    }

    private func setAIModel(modelName: String?) async {
        let mutation = """
        mutation {
            setAiModel(modelName: \(modelName.map { "\"\($0)\"" } ?? "null")) {
                selectedModel
                currentProvider
            }
        }
        """

        guard let url = URL(string: APIConfig.currentGraphqlURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = ["query": mutation]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            await fetchModelConfig()
        } catch {
            print("Failed to set model: \(error)")
        }
    }
}

// MARK: - Model Usage Card

struct ModelUsageCard: View {
    let model: ModelUsageStats

    var usageColor: Color {
        if model.percentageUsed >= 90 { return .red }
        if model.percentageUsed >= 70 { return .orange }
        if model.percentageUsed >= 50 { return .blue }
        return .green
    }

    var priorityColor: Color {
        switch model.priority {
        case 1: return .purple
        case 2: return .blue
        case 3: return .green
        case 4: return .yellow
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.displayName)
                        .font(.headline)
                        .foregroundStyle(Color.appText)
                    Text(model.useCase)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Badge(text: model.priorityLabel, color: priorityColor)
            }

            // Usage Progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(model.currentUsage) / \(model.dailyLimit)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appText)
                    Spacer()
                    Text("\(Int(model.percentageUsed))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(usageColor)
                }

                ProgressView(value: model.percentageUsed, total: 100)
                    .tint(usageColor)
                    .scaleEffect(y: 2)
            }

            // Token Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Input Tokens")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(formatNumber(model.totalInputTokens))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appText)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Output Tokens")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(formatNumber(model.totalOutputTokens))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Remaining")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(formatNumber(model.remaining))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .padding(.horizontal)
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        }
        return "\(number)"
    }
}

// MARK: - Badge Component

struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Model Picker Sheet

struct ModelPickerSheet: View {
    let availableModels: [String]
    @Binding var selectedModel: String?
    let currentPriorityOrder: [String]
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var mode: SelectionMode = .single
    @State private var tempSelection: String?
    @State private var tempPriorityOrder: [String] = []
    @State private var enabledModels: Set<String> = []
    @Environment(\.editMode) var editMode

    enum SelectionMode: String, CaseIterable {
        case single = "Single Model"
        case smart = "Smart Routing"
        case fallback = "Fallback Chain"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode Picker
                Picker("Mode", selection: $mode) {
                    ForEach(SelectionMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: mode) { oldValue, newValue in
                    // When switching to fallback mode, ensure we have all models
                    if newValue == .fallback && tempPriorityOrder.isEmpty {
                        tempPriorityOrder = availableModels
                        enabledModels = Set(availableModels)
                    }
                }

                switch mode {
                case .single:
                    singleModelView
                case .smart:
                    smartRoutingView
                case .fallback:
                    fallbackChainView
                }
            }
            .navigationTitle("AI Model Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConfiguration()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempSelection = selectedModel

            // Determine mode: Single if model selected, Smart if no priority order, Fallback if priority order exists
            if selectedModel != nil {
                mode = .single
                tempPriorityOrder = availableModels
                enabledModels = Set(availableModels)
            } else if currentPriorityOrder.isEmpty {
                mode = .smart
                tempPriorityOrder = availableModels
                enabledModels = Set(availableModels)
            } else {
                mode = .fallback
                // Start with current order, then add disabled models at the end
                var fullOrder = currentPriorityOrder
                enabledModels = Set(currentPriorityOrder)
                for model in availableModels {
                    if !fullOrder.contains(model) {
                        fullOrder.append(model)
                    }
                }
                tempPriorityOrder = fullOrder
            }

            print("DEBUG: Mode=\(mode), currentPriorityOrder=\(currentPriorityOrder), tempPriorityOrder=\(tempPriorityOrder)")
        }
    }

    private var singleModelView: some View {
        List {
            Section {
                ForEach(availableModels, id: \.self) { model in
                    Button {
                        tempSelection = model
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(modelDisplayName(model))
                                    .font(.body)
                                    .foregroundStyle(Color.appText)
                                Text(modelProvider(model))
                                    .font(.caption)
                                    .foregroundStyle(Color.appMuted)
                            }
                            Spacer()
                            if tempSelection == model {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.primaryBrown)
                            }
                        }
                    }
                }
            } header: {
                Text("Select One Model")
            } footer: {
                Text("All requests will use the selected model exclusively")
            }
        }
    }

    private var smartRoutingView: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundStyle(Color.primaryBrown)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Automatic Model Selection")
                                .font(.headline)
                                .foregroundStyle(Color.appText)
                            Text("AI will intelligently choose the best model based on request complexity")
                                .font(.caption)
                                .foregroundStyle(Color.appMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Divider()
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How it works:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.appText)

                        Label("Simple queries → Fast, efficient models", systemImage: "bolt.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appMuted)

                        Label("Complex requests → Advanced models", systemImage: "sparkles")
                            .font(.caption)
                            .foregroundStyle(Color.appMuted)

                        Label("Optimal cost and performance balance", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundStyle(Color.appMuted)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Smart Routing Enabled")
            } footer: {
                Text("The system will automatically select the most appropriate model for each request")
            }
        }
        .listStyle(.insetGrouped)
    }

    private var fallbackChainView: some View {
        List {
            Section {
                ForEach(tempPriorityOrder, id: \.self) { model in
                    HStack(spacing: 12) {
                        Toggle("", isOn: Binding(
                            get: { enabledModels.contains(model) },
                            set: { isEnabled in
                                if isEnabled {
                                    enabledModels.insert(model)
                                } else {
                                    enabledModels.remove(model)
                                }
                            }
                        ))
                        .labelsHidden()

                        VStack(alignment: .leading, spacing: 4) {
                            Text(modelDisplayName(model))
                                .font(.body)
                                .foregroundStyle(enabledModels.contains(model) ? Color.appText : Color.appText.opacity(0.4))
                            Text(modelProvider(model))
                                .font(.caption)
                                .foregroundStyle(enabledModels.contains(model) ? Color.appMuted : Color.appMuted.opacity(0.4))
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .onMove { from, to in
                    tempPriorityOrder.move(fromOffsets: from, toOffset: to)
                }
            } header: {
                Text("Fallback Priority Order")
            } footer: {
                Text("Toggle models on/off and drag to reorder. Enabled models will be tried from top to bottom until one succeeds.")
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(.active))
    }

    private func saveConfiguration() {
        Task {
            switch mode {
            case .single:
                // Save specific model selection
                await setAIModelWithPriority(modelName: tempSelection, priorityOrder: nil)
            case .smart:
                // Save smart routing (no specific model, use default/all models for smart routing)
                await setAIModelWithPriority(modelName: nil, priorityOrder: nil)
            case .fallback:
                // Save fallback chain - only include enabled models
                let enabledOrderedModels = tempPriorityOrder.filter { enabledModels.contains($0) }
                await setAIModelWithPriority(modelName: nil, priorityOrder: enabledOrderedModels)
            }
            onSave()
            dismiss()
        }
    }

    private func setAIModelWithPriority(modelName: String?, priorityOrder: [String]?) async {
        let priorityOrderString = priorityOrder?.map { "\"\($0)\"" }.joined(separator: ", ")
        let mutation = """
        mutation {
            setAiModel(
                modelName: \(modelName.map { "\"\($0)\"" } ?? "null")
                \(priorityOrder != nil ? "priorityOrder: [\(priorityOrderString!)]" : "")
            ) {
                selectedModel
                currentProvider
                modelPriorityOrder
            }
        }
        """

        print("DEBUG: Mutation being sent:")
        print(mutation)

        guard let url = URL(string: APIConfig.currentGraphqlURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = ["query": mutation]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("DEBUG: Response:")
                print(json)
            }
        } catch {
            print("Failed to set model: \(error)")
        }
    }

    private func modelDisplayName(_ model: String) -> String {
        // Extract readable name from model string
        // e.g., "deepseek/deepseek-chat-v3.1:free" -> "DeepSeek Chat v3.1"
        if model.contains("deepseek") {
            return "DeepSeek Chat v3.1"
        } else if model.contains("qwen") {
            return "Qwen3 30B A3B"
        } else if model.contains("gemini-2.5-pro") {
            return "Gemini 2.5 Pro"
        } else if model.contains("flash-preview") {
            return "Gemini 2.5 Flash Preview"
        } else if model.contains("flash-lite") {
            return "Gemini 2.5 Flash Lite"
        } else if model.contains("flash") {
            return "Gemini 2.5 Flash"
        }
        return model
    }

    private func modelProvider(_ model: String) -> String {
        if model.contains("/") {
            return "OpenRouter (Free)"
        } else {
            return "Google Gemini"
        }
    }
}

#Preview {
    NavigationStack {
        AIUsageView()
    }
}
