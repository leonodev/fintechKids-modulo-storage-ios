//
//  StorageManager.swift
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

// MARK: - Keychain & System API
extension FHKStorageManager {
    
    public func saveKeychain<T: Codable & Sendable>(_ value: T, for key: String, requireBiometry: Bool = false) throws {
        let data = try JSONEncoder().encode(value)
        try saveKeychainData(data, key, requireBiometry)
    }
    
    public func readKeychain<T: Decodable & Sendable>(_ type: T.Type, for key: String, prompt: String? = nil) throws -> T? {
        guard let data = try readKeychainData(key, prompt) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func deleteKeychain(_ key: String) throws {
        try deleteKeychainData(key)
    }
    
    public func containsKeychain(_ key: String) -> Bool {
        containsKeychainKey(key)
    }
    
    public func clearAllKeychain() throws {
        try clearAllKeychainData()
    }
    
    public func isBiometryAvailable() -> Bool {
        isBiometryAvailableAction()
    }
    
    public func exists(key: String) -> Bool {
        existsKeyAction(key)
    }
}

extension FHKStorageManager {
    public func clearKeychainIfNewInstallation() async {
        let firstTimeRunAppKey = "first_time_run_app"
        
        do {
            let hasRunBefore = try await readUserDefaults(Bool.self, forKey: firstTimeRunAppKey) ?? false
            
            if !hasRunBefore {
                try clearAllKeychain()
                try await saveUserDefaults(true, forKey: firstTimeRunAppKey)
            }
        } catch {
            Logger.error("❌ Error proccessing Keychain Cleanup: \(error)")
        }
    }
}

extension FHKStorageManager {
    
    public static func live(userDefault: FHKUserDefaultsProtocol, keychain: FHKKeychainProtocol) -> Self {
        var manager = Self()
        
        manager.saveUserDefaultsData = { value, key in try await userDefault.save(value, forKey: key) }
        manager.readUserDefaultsData = { key in try await userDefault.read(Data.self, forKey: key) }
        manager.deleteUserDefaultsData = { key in try await userDefault.delete(forKey: key) }
        
        manager.saveKeychainData = { data, key, biometry in try keychain.save(data, for: key, requireBiometry: biometry) }
        manager.readKeychainData = { key, prompt in try keychain.read(Data.self, for: key, prompt: prompt) }
        manager.deleteKeychainData = { key in try keychain.delete(key) }
        manager.containsKeychainKey = { key in keychain.contains(key) }
        manager.clearAllKeychainData = { try keychain.clearAll() }
        
        manager.isBiometryAvailableAction = {
            let context = LAContext()
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        }
        
        manager.existsKeyAction = { key in
            let context = LAContext()
            context.interactionNotAllowed = true
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecUseAuthenticationContext as String: context,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            return status == errSecSuccess || status == errSecInteractionNotAllowed
        }
        
        return manager
    }
}

extension FHKStorageManager {
    
    public static var test: Self {
        // Usamos contenedores thread-safe o copias locales en los closures
        // Para simular persistencia en memoria durante un test simple:
        return Self(
            // Configura aquí comportamientos base si los necesitas,
            // de lo contrario, el init por defecto ya los deja vacíos listos para pisar.
        )
    }
}

//// UserDefault Methods
//public final class FHKStorageManager: FHKStorageManagerProtocol  {
//    public let userDefault: FHKUserDefaultsProtocol
//    public let keychain: FHKKeychainProtocol
//    
//    public init(userDefault: FHKUserDefaultsProtocol,
//                keychain: FHKKeychainProtocol) {
//        self.userDefault = userDefault
//        self.keychain = keychain
//    }
//    
//    public func saveUserDefaults<T: Encodable & Sendable>(_ value: T, forKey key: String) async throws {
//        try await userDefault.save(value, forKey: key)
//    }
//    
//    
//    public func readUserDefaults<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
//        try await userDefault.read(type, forKey: key)
//    }
//    
//    
//    public func updateUserDefaults<T>(_ type: T.Type,
//                   forKey key: String,
//                   update: @Sendable (T?) -> T?
//    ) async throws where T: Decodable, T: Encodable, T: Sendable {
//        try await userDefault.update(type, forKey: key, update: update)
//    }
//    
//    
//    public func deleteUserDefaults(forKey key: String) async throws {
//        try await userDefault.delete(forKey: key)
//    }
//}
//
//// Keychain Methods
//public extension FHKStorageManager {
//    
//    func saveKeychain<T: Codable & Sendable>(_ value: T,
//                                                    for key: String,
//                                                    requireBiometry: Bool = false) throws {
//        try keychain.save(value, for: key, requireBiometry: requireBiometry)
//    }
//    
//    
//    func readKeychain<T: Decodable & Sendable>(_ type: T.Type,
//                                                      for key: String,
//                                                      prompt: String? = nil) throws -> T? {
//            try keychain.read(type, for: key, prompt: prompt)
//        }
//    
//    func deleteKeychain(_ key: String) throws {
//        try keychain.delete(key)
//    }
//    
//    func containsKeychain(_ key: String) -> Bool {
//        keychain.contains(key)
//    }
//    
//    func clearAllKeychain() throws {
//        try keychain.clearAll()
//    }
//    
//    func isBiometryAvailable() -> Bool {
//        let context = LAContext()
//        var error: NSError?
//        
//        // .deviceOwnerAuthenticationWithBiometrics valida solo FaceID/TouchID
//        // .deviceOwnerAuthentication valida biometría O el código del iPhone
//        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
//        
//        return canEvaluate
//    }
//    
//    func exists(key: String) -> Bool {
//        let context = LAContext()
//            context.interactionNotAllowed = true
//        
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: key,
//            kSecUseAuthenticationContext as String: context,
//            kSecMatchLimit as String: kSecMatchLimitOne
//        ]
//        
//        let status = SecItemCopyMatching(query as CFDictionary, nil)
//        
//        // errSecSuccess significa que existe y se pudo acceder
//        // errSecInteractionNotAllowed significa que EXISTE pero requiere biometría (así que existe)
//        return status == errSecSuccess || status == errSecInteractionNotAllowed
//    }
//    
//    func clearKeychainIfNewInstallation() async {
//        let firstTimeRunAppKey = "first_time_run_app"
//        
//        do { 
//            let hasRunBefore = try await userDefault.read(Bool.self, forKey: firstTimeRunAppKey) ?? false
//            
//            if !hasRunBefore {
//                Logger.info("🧹New Installation or Reinstallation Detected! Purging Keychain...")
//                try keychain.clearAll()
//                
//                try await userDefault.save(true, forKey: firstTimeRunAppKey)
//                Logger.info("✅ Flag saved, the Keychain will not be cleared on future launches.")
//            } else {
//                Logger.info("📱 the app was executed before. Not clearing Keychain.")
//            }
//        } catch {
//            Logger.error("⚠️ Error proccessing Keychain Cleanup: \(error)")
//        }
//    }
//}

