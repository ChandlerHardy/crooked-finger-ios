//
//  SettingsView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @State private var notificationsEnabled = true
    @State private var hapticFeedback = true

    var body: some View {
        @Bindable var viewModel = authViewModel

        Form {
            Section("Account") {
                if let user = viewModel.currentUser {
                    HStack {
                        Text("Email")
                            .foregroundStyle(Color.appText)
                        Spacer()
                        Text(user.email)
                            .foregroundStyle(Color.appMuted)
                    }
                }

                NavigationLink {
                    AIUsageView()
                } label: {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(Color.primaryBrown)
                        Text("AI Usage Dashboard")
                            .foregroundStyle(Color.appText)
                    }
                }

                Button("Log Out") {
                    viewModel.logout()
                }
                .foregroundStyle(.red)
            }

            Section("App Settings") {
                Picker("Appearance", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .tint(Color.primaryBrown)

                Toggle("Notifications", isOn: $notificationsEnabled)
                    .tint(Color.primaryBrown)
                Toggle("Haptic Feedback", isOn: $hapticFeedback)
                    .tint(Color.primaryBrown)
            }

            Section("About") {
                HStack {
                    Text("Version")
                        .foregroundStyle(Color.appText)
                    Spacer()
                    Text(AppConstants.appVersion)
                        .foregroundStyle(Color.appMuted)
                }

                HStack {
                    Text("App Name")
                        .foregroundStyle(Color.appText)
                    Spacer()
                    Text(AppConstants.appName)
                        .foregroundStyle(Color.appMuted)
                }
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://crookedfinger.chandlerhardy.com")!)
                    .foregroundStyle(Color.primaryBrown)
                Link("Terms of Service", destination: URL(string: "https://crookedfinger.chandlerhardy.com")!)
                    .foregroundStyle(Color.primaryBrown)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
