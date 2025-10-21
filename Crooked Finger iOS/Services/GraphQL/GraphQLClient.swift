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
    private let secureStorage = SecureStorageService.shared
    var authToken: String? {
        didSet {
            // Save to secure storage when token changes
            if let token = authToken {
                _ = secureStorage.saveString(token, forKey: "authToken")
            } else {
                _ = secureStorage.delete(forKey: "authToken")
            }
        }
    }

    private init() {
        self.endpoint = URL(string: APIConfig.currentGraphqlURL)!
        self.session = URLSession.shared
        // Load saved token from secure storage
        self.authToken = secureStorage.loadString(forKey: "authToken")
    }

    /// Execute a GraphQL query or mutation
    func execute<T: Decodable>(
        query: String,
        variables: [String: Any]? = nil
    ) async throws -> T {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

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
