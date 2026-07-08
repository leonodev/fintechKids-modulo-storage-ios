//
//  FHKStorageManager.swift
//  FHKStorage
//
//  Created by fleon  on 8/7/26.
//

import Foundation
import LocalAuthentication
import FHKDomain
import FHKUtils

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
