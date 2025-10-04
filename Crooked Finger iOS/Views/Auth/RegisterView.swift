//
//  RegisterView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss

    var passwordsMatch: Bool {
        password == confirmPassword
    }

    var body: some View {
        @Bindable var viewModel = authViewModel

        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "hand.point.up.braille.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.primaryBrown)

                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appText)

                    Text("Join Crooked Finger")
                        .font(.subheadline)
                        .foregroundStyle(Color.appMuted)
                }
                .padding(.top, 40)

                // Register Form
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
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    !confirmPassword.isEmpty && !passwordsMatch ? Color.red : Color.appBorder,
                                    lineWidth: 1
                                )
                        )
                }
                .padding(.horizontal)

                // Password Match Warning
                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Register Button
                Button {
                    Task {
                        let success = await viewModel.register(email: email, password: password)
                        if success {
                            dismiss()  // Close register sheet and show login
                        }
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
                        Text("Create Account")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryBrown)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .disabled(email.isEmpty || password.isEmpty || !passwordsMatch || viewModel.isLoading)
                .padding(.horizontal)

                // Login Link
                Button {
                    dismiss()
                } label: {
                    Text("Already have an account? **Log In**")
                        .font(.subheadline)
                        .foregroundStyle(Color.appText)
                }
                .padding(.top, 8)

                Spacer()
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
