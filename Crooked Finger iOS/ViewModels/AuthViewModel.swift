//
//  AuthViewModel.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

@MainActor
@Observable
class AuthViewModel {
    var isAuthenticated = false
    var currentUser: UserResponse?
    var isLoading = false
    var errorMessage: String?

    private let client = GraphQLClient.shared

    init() {
        // Check if we have a saved token
        isAuthenticated = client.authToken != nil
    }

    // MARK: - Login

    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let variables: [String: Any] = [
                "input": [
                    "email": email,
                    "password": password
                ]
            ]

            let response: LoginData = try await client.execute(
                query: GraphQLOperations.login,
                variables: variables
            )

            // Save token
            let token = response.login.accessToken
            client.authToken = token
            currentUser = response.login.user

            print("✅ Login successful!")
            print("   Token received: \(token.prefix(20))...")
            print("   User: \(response.login.user.email)")
            print("   Token in client: \(client.authToken?.prefix(20) ?? "nil")...")
            print("   Token in UserDefaults: \(UserDefaults.standard.string(forKey: "authToken")?.prefix(20) ?? "nil")...")

            // Verify token was saved
            if client.authToken != nil {
                isAuthenticated = true
                print("   ✅ isAuthenticated set to true")
            } else {
                print("   ❌ Token NOT saved to client!")
            }

            isLoading = false
            return true

        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
            print("❌ Login error: \(error)")
            isLoading = false
            return false
        }
    }

    // MARK: - Register

    func register(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let variables: [String: Any] = [
                "input": [
                    "email": email,
                    "password": password
                ]
            ]

            let response: RegisterData = try await client.execute(
                query: GraphQLOperations.register,
                variables: variables
            )

            // Save token
            client.authToken = response.register.accessToken
            currentUser = response.register.user
            isAuthenticated = true

            isLoading = false
            return true

        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
            print("❌ Registration error: \(error)")
            isLoading = false
            return false
        }
    }

    // MARK: - Logout

    func logout() {
        client.authToken = nil
        currentUser = nil
        isAuthenticated = false
    }
}
