
//
//  FHKStorageManager+Live.swift
//  FHKStorage
//
//  Created by fleon  on 8/7/26.
//

import Foundation
import LocalAuthentication
import FHKDomain
import FHKUtils

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
