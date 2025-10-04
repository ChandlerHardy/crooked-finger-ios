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

#Preview {
    NavigationStack {
        AIUsageView()
    }
}
