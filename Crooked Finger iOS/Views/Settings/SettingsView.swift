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
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
