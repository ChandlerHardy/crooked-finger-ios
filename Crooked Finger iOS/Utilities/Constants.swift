//
//  Constants.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import Foundation

enum APIConfig {
    static let graphqlURL = "https://backend.chandlerhardy.com/crooked-finger/graphql"
    static let localGraphqlURL = "http://localhost:8001/crooked-finger/graphql"

    #if DEBUG
    static let currentGraphqlURL = graphqlURL  // Always use production backend
    #else
    static let currentGraphqlURL = graphqlURL
    #endif
}

enum AppConstants {
    static let appName = "Crooked Finger"
    static let appVersion = "1.0.0"
}
