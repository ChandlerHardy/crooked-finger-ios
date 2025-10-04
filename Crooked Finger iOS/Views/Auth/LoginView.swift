//
//  LoginView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        @Bindable var viewModel = authViewModel

        NavigationStack {
            VStack(spacing: 24) {
                // Logo/Header
                VStack(spacing: 12) {
                    Image(systemName: "hand.point.up.braille.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.primaryBrown)

                    Text("Crooked Finger")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appText)

                    Text("Your crochet pattern assistant")
                        .font(.subheadline)
                        .foregroundStyle(Color.appMuted)
                }
                .padding(.top, 40)

                // Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Debug: Show auth status
                if let token = GraphQLClient.shared.authToken {
                    Text("✅ Authenticated - Token: \(token.prefix(10))...")
                        .font(.caption2)
                        .foregroundStyle(.green)
                        .padding(.horizontal)
                } else {
                    Text("❌ No auth token")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .padding(.horizontal)
                }

                // Login Button
                Button {
                    Task {
                        await viewModel.login(email: email, password: password)
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryBrown)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("Log In")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryBrown)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
                .padding(.horizontal)

                // Register Link
                Button {
                    showRegister = true
                } label: {
                    Text("Don't have an account? **Sign Up**")
                        .font(.subheadline)
                        .foregroundStyle(Color.appText)
                }
                .padding(.top, 8)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    LoginView()
}
