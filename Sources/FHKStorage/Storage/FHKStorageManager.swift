//
//  StorageManager.swift
//  FHKStorage
//
//  Created by Fredy Leon on 11/2/26.
//

import Foundation
import LocalAuthentication

public protocol FHKStorageManagerProtocol: Sendable {
    func saveUserDefaults<T: Encodable & Sendable>(_ value: T, forKey key: String) async throws
    func readUserDefaults<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T?
    func updateUserDefaults<T>(_ type: T.Type,
                   forKey key: String,
                   update: @Sendable (T?) -> T?) async throws where T: Decodable, T: Encodable, T: Sendable
    func deleteUserDefaults(forKey key: String) async throws
    
    func saveKeychain<T: Codable & Sendable>(_ value: T,
                                             for key: String,
                                             requireBiometry: Bool) throws
    
    func readKeychain<T: Decodable & Sendable>(_ type: T.Type,
                                               for key: String,
                                               prompt: String?) throws -> T?
    
    func deleteKeychain(_ key: String) throws
    
    func containsKeychain(_ key: String) -> Bool
    
    func clearAllKeychain() throws
    
    func isBiometryAvailable() -> Bool
}

// UserDefault Methods
public final class FHKStorageManager: FHKStorageManagerProtocol  {
    public let userDefault: FHKUserDefaultsProtocol
    public let keychain: FHKKeychainProtocol
    
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
public extension FHKStorageManager {
    
    public func saveKeychain<T: Codable & Sendable>(_ value: T,
                                                    for key: String,
                                                    requireBiometry: Bool = false) throws {
        try keychain.save(value, for: key, requireBiometry: requireBiometry)
    }
    
    
    public func readKeychain<T: Decodable & Sendable>(_ type: T.Type,
                                                      for key: String,
                                                      prompt: String? = nil) throws -> T? {
            try keychain.read(type, for: key, prompt: prompt)
        }
    
    public func deleteKeychain(_ key: String) throws {
        try keychain.delete(key)
    }
    
    public func containsKeychain(_ key: String) -> Bool {
        try keychain.contains(key)
    }
    
    public func clearAllKeychain() throws {
        try keychain.clearAll()
    }
    
    public func isBiometryAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // .deviceOwnerAuthenticationWithBiometrics valida solo FaceID/TouchID
        // .deviceOwnerAuthentication valida biometría O el código del iPhone
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        return canEvaluate
    }
}
