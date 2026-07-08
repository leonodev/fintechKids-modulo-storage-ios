//
//  FHKStorageManager+UserDefaults.swift
//  FHKStorage
//
//  Created by Fredy Leon on 11/2/26.
//

import Foundation
import LocalAuthentication
import FHKDomain
import FHKUtils

// MARK: - UserDefaults API
extension FHKStorageManager {
    
    public func saveUserDefaults<T: Encodable & Sendable>(_ value: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(value)
        try await saveUserDefaultsData(data, key)
    }
    
    public func readUserDefaults<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = try await readUserDefaultsData(key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func updateUserDefaults<T>(_ type: T.Type, forKey key: String, update: @Sendable (T?) -> T?) async throws where T: Decodable, T: Encodable, T: Sendable {
        let current = try await readUserDefaults(type, forKey: key)
        if let updated = update(current) {
            try await saveUserDefaults(updated, forKey: key)
        } else {
            try await deleteUserDefaults(forKey: key)
        }
    }
    
    public func deleteUserDefaults(forKey key: String) async throws {
        try await deleteUserDefaultsData(key)
    }
}
