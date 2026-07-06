//
//  FHKStorageManagerMock.swift
//  FHKStorage
//
//  Created by fleon  on 6/7/26.
//

import Foundation
import LocalAuthentication
import FHKDomain
import FHKUtils

public final class FHKStorageManagerMock: FHKStorageManagerProtocol, @unchecked Sendable {
    
    private let lock = NSLock()
    private var userDefaultsStorage: [String: Data] = [:]
    private var keychainStorage: [String: Data] = [:]
    
    public var biometryAvailable: Bool
    
    public init(
        biometryAvailable: Bool = true,
        initialUserDefaults: [String: Data] = [:],
        initialKeychain: [String: Data] = [:]
    ) {
        self.biometryAvailable = biometryAvailable
        self.userDefaultsStorage = initialUserDefaults
        self.keychainStorage = initialKeychain
    }
    
    // MARK: - Keychain Methods (Swift 6 Safe)
    public func saveKeychain<T>(_ value: T, for key: String, requireBiometry: Bool) throws where T : Decodable, T : Encodable, T : Sendable {
        // Al usar try antes de lock.withLock, si el encode falla, se propaga limpiamente hacia afuera
        try lock.withLock {
            let data = try JSONEncoder().encode(value)
            keychainStorage[key] = data
        }
    }
    
    public func readKeychain<T>(_ type: T.Type, for key: String, prompt: String?) throws -> T? where T : Decodable, T : Sendable {
        try lock.withLock {
            guard let data = keychainStorage[key] else { return nil }
            return try JSONDecoder().decode(type, from: data)
        }
    }
    
    public func deleteKeychain(_ key: String) throws {
        lock.withLock {
            keychainStorage.removeValue(forKey: key)
        }
    }
    
    public func containsKeychain(_ key: String) -> Bool {
        lock.withLock {
            keychainStorage[key] != nil
        }
    }
    
    public func clearAllKeychain() throws {
        lock.withLock {
            keychainStorage.removeAll()
        }
    }
    
    // MARK: - UserDefaults Methods (Swift 6 Safe)
    
    public func saveUserDefaults<T>(_ value: T, forKey key: String) async throws where T : Encodable, T : Sendable {
        try lock.withLock {
            let data = try JSONEncoder().encode(value)
            userDefaultsStorage[key] = data
        }
    }
    
    public func readUserDefaults<T>(_ type: T.Type, forKey key: String) async throws -> T? where T : Decodable, T : Sendable {
        try lock.withLock {
            guard let data = userDefaultsStorage[key] else { return nil }
            return try JSONDecoder().decode(type, from: data)
        }
    }
    
    public func updateUserDefaults<T>(_ type: T.Type, forKey key: String, update: @Sendable (T?) -> T?) async throws where T : Decodable, T : Encodable, T : Sendable {
        try lock.withLock {
            var currentItem: T? = nil
            if let data = userDefaultsStorage[key] {
                currentItem = try? JSONDecoder().decode(type, from: data)
            }
            
            let updatedItem = update(currentItem)
            
            if let updatedItem {
                let data = try JSONEncoder().encode(updatedItem)
                userDefaultsStorage[key] = data
            } else {
                userDefaultsStorage.removeValue(forKey: key)
            }
        }
    }
    
    public func deleteUserDefaults(forKey key: String) async throws {
        lock.withLock {
            userDefaultsStorage.removeValue(forKey: key)
        }
    }
    
    // MARK: - Helpers
    
    public func isBiometryAvailable() -> Bool {
        return biometryAvailable
    }
    
    public func exists(key: String) -> Bool {
        lock.withLock {
            userDefaultsStorage[key] != nil || keychainStorage[key] != nil
        }
    }
    
    public func clearKeychainIfNewInstallation() async {
        // No requiere sincronización para Previews
    }
}
