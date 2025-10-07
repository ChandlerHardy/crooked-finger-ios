//
//  Crooked_Finger_iOSApp.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

@main
struct Crooked_Finger_iOSApp: App {
    let authViewModel = AuthViewModel()
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    TabNavigationView()
                } else {
                    LoginView()
                }
            }
            .environment(authViewModel)
            .preferredColorScheme(appearanceMode.colorScheme)
        }
    }
}
