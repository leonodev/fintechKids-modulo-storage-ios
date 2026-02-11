//
//  StorageManager.swift
//  FHKStorage
//
//  Created by Fredy Leon on 11/2/26.
//

import Foundation

public protocol FHKStorageManagerProtocol {
    var userDefault: FHKUserDefaultsProtocol { get }
    var keychain: FHKKeychainProtocol { get }
    
    func saveUserDefaults<T: Encodable & Sendable>(_ value: T, forKey key: String) async throws
    func readUserDefaults<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T?
    func updateUserDefaults<T>(_ type: T.Type,
                   forKey key: String,
                   update: @Sendable (T?) -> T?) async throws where T: Decodable, T: Encodable, T: Sendable
    func deleteUserDefaults(forKey key: String) async throws
}

// UserDefault Methods
public class FHKStorageManager: FHKStorageManagerProtocol  {
    public var userDefault: FHKUserDefaultsProtocol
    public var keychain: FHKKeychainProtocol
    
    public init(userDefault: FHKUserDefaultsProtocol,
                keychain: FHKKeychainProtocol) {
        self.userDefault = userDefault
        self.keychain = keychain
    }
    
    public func saveUserDefaults<T: Encodable & Sendable>(_ value: T, forKey key: String) async throws {
        try await userDefault.save(value, forKey: key)
    }
    
    
    public func readUserDefaults<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        try await userDefault.read(type, forKey: key)
    }
    
    
    public func updateUserDefaults<T>(_ type: T.Type,
                   forKey key: String,
                   update: @Sendable (T?) -> T?
    ) async throws where T: Decodable, T: Encodable, T: Sendable {
        try await userDefault.update(type, forKey: key, update: update)
    }
    
    
    public func deleteUserDefaults(forKey key: String) async throws {
        try await userDefault.delete(forKey: key)
    }
}

// Keychain Methods
extension FHKStorageManager {
    
    func saveKeychain<T: Codable & Sendable>(_ value: T, for key: String) throws {
        try keychain.save(value, for: key)
    }
    
    
    func readKeychain<T: Decodable & Sendable>(_ type: T.Type, for key: String) throws -> T? {
        try keychain.read(type, for: key)
    }
    
    func deleteKeychain(_ key: String) throws {
        try keychain.delete(key)
    }
    
    func containsKeychain(_ key: String) -> Bool {
        try keychain.contains(key)
    }
    
    func clearAllKeychain() throws {
        try keychain.clearAll()
    }
}
