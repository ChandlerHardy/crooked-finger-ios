//
//  Crooked_Finger_iOSApp.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

@main
struct Crooked_Finger_iOSApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            // TODO: Re-enable auth when backend bcrypt is fixed
            // Auth temporarily disabled - backend bcrypt library has bugs
            TabNavigationView()
                .background(Color.appBackground)
                .preferredColorScheme(nil) // Respect system setting
                .environment(authViewModel)
        }
    }
}
