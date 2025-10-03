//
//  SettingsView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var hapticFeedback = true

    var body: some View {
        Form {
            Section("App Settings") {
                Toggle("Notifications", isOn: $notificationsEnabled)
                Toggle("Haptic Feedback", isOn: $hapticFeedback)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(AppConstants.appVersion)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("App Name")
                    Spacer()
                    Text(AppConstants.appName)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://crookedfinger.chandlerhardy.com")!)
                Link("Terms of Service", destination: URL(string: "https://crookedfinger.chandlerhardy.com")!)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
