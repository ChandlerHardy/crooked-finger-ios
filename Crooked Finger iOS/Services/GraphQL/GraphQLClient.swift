//
//  GraphQLClient.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

/// Simple GraphQL client using URLSession (no Apollo codegen needed for now)
/// This provides a lightweight way to make GraphQL requests without complex setup
class GraphQLClient {
    static let shared = GraphQLClient()

    private let endpoint: URL
    private let session: URLSession
    var authToken: String? {
        didSet {
            // Save to UserDefaults when token changes
            if let token = authToken {
                UserDefaults.standard.set(token, forKey: "authToken")
                UserDefaults.standard.synchronize() // Force save
                print("💾 Token saved to UserDefaults: \(token.prefix(20))...")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.synchronize()
                print("🗑️  Token removed from UserDefaults")
            }
        }
    }

    private init() {
        self.endpoint = URL(string: APIConfig.currentGraphqlURL)!
        self.session = URLSession.shared
        // Load saved token
        if let savedToken = UserDefaults.standard.string(forKey: "authToken") {
            self.authToken = savedToken
            print("📂 Loaded saved token from UserDefaults: \(savedToken.prefix(20))...")
        } else {
            print("📂 No saved token in UserDefaults")
        }
    }

    /// Execute a GraphQL query or mutation
    func execute<T: Decodable>(
        query: String,
        variables: [String: Any]? = nil
    ) async throws -> T {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // TODO: Re-enable auth when backend bcrypt is fixed
        // Auth disabled temporarily - backend bcrypt library has bugs
        /*
        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 GraphQL request with auth token: \(token.prefix(20))...")
        } else {
            print("⚠️  GraphQL request WITHOUT auth token")
        }
        */
        print("ℹ️  Auth temporarily disabled")

        let body: [String: Any] = [
            "query": query,
            "variables": variables ?? [:]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GraphQLError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw GraphQLError.httpError(statusCode: httpResponse.statusCode)
        }

        // Parse GraphQL response
        let graphQLResponse = try JSONDecoder().decode(GraphQLResponse<T>.self, from: data)

        if let errors = graphQLResponse.errors {
            throw GraphQLError.graphQLErrors(errors)
        }

        guard let data = graphQLResponse.data else {
            throw GraphQLError.noData
        }

        return data
    }
}

// MARK: - Response Types

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLErrorDetail]?
}

struct GraphQLErrorDetail: Decodable {
    let message: String
    let path: [String]?
}

// MARK: - Error Types

enum GraphQLError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case graphQLErrors([GraphQLErrorDetail])
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .graphQLErrors(let errors):
            return errors.map { $0.message }.joined(separator: ", ")
        case .noData:
            return "No data returned from server"
        }
    }
}
