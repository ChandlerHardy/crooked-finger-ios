//
//  SplashScreenView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/6/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        ZStack {
            // Main app content
            MainContentView()
                .opacity(isActive ? 1 : 0)

            // Splash screen overlay
            if !isActive {
                Color.accentLight
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .scaleEffect(size)
                        .opacity(opacity)

                    Text("Crooked Finger")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primaryBrown)
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            // Animate logo
            withAnimation(.easeIn(duration: 0.8)) {
                self.size = 1.0
                self.opacity = 1.0
            }

            // Transition to main app
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    self.isActive = true
                }
            }
        }
    }
}

// Separate view to handle auth state
private struct MainContentView: View {
    let authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabNavigationView()
            } else {
                LoginView()
            }
        }
        .environment(authViewModel)
    }
}

#Preview {
    SplashScreenView()
}
