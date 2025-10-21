//
//  SecureStorageService.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/20/25.
//

import Foundation
import Security

/// Secure storage service for sensitive data like authentication tokens
class SecureStorageService {
    static let shared = SecureStorageService()
    
    private let service = "com.chandlerhardy.crooked-finger-ios"
    
    private init() {}
    
    // MARK: - Generic Functions
    
    func save(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Try to add first
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        
        if addStatus == errSecSuccess {
            return true
        } else if addStatus == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            return updateStatus == errSecSuccess
        }
        
        return false
    }
    
    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Convenience Methods
    
    func saveString(_ string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        guard let data = load(forKey: key),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
    
    func saveBool(_ value: Bool, forKey key: String) -> Bool {
        let data = value ? Data([1]) : Data([0])
        return save(data, forKey: key)
    }
    
    func loadBool(forKey key: String) -> Bool {
        guard let data = load(forKey: key),
              let byte = data.first else {
            return false
        }
        return byte != 0
    }
    
    func saveInt(_ value: Int, forKey key: String) -> Bool {
        let data = withUnsafeBytes(of: value) { Data($0) }
        return save(data, forKey: key)
    }
    
    func loadInt(forKey key: String) -> Int? {
        guard let data = load(forKey: key),
              data.count == MemoryLayout<Int>.size else {
            return nil
        }
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }
}