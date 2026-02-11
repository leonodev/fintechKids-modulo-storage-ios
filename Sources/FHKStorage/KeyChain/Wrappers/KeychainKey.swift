//
//  KeychainKey.swift
//  FHKStorage
//
//  Created by Fredy Leon on 13/12/25.
//

import Foundation

public enum KeychainKey: String, CaseIterable, Sendable {
    case authToken
    case refreshToken
    case userCredentials
    case appSettings
    case biometricData
    case appLanguage
}

@propertyWrapper
struct KeychainStored<T: Codable & Sendable>: Sendable {
    private let key: String
    private let storage: FHKKeychainProtocol
    
    init(_ key: KeychainKey, storage: FHKKeychainProtocol) {
        self.key = key.rawValue
        self.storage = storage
    }
    
    var wrappedValue: T? {
        get { try? storage.read(T.self, for: key) }
        set {
            do {
                if let value = newValue {
                    try storage.save(value, for: key)
                } else {
                    try storage.delete(key)
                }
            } catch {
                print("🔐 Keychain error: \(error)")
            }
        }
    }
}

@propertyWrapper
struct KeychainString: Sendable {
    private let key: String
    private let storage: FHKKeychainProtocol
    
    init(_ key: KeychainKey, storage: FHKKeychainProtocol) {
        self.key = key.rawValue
        self.storage = storage
    }
    
    var wrappedValue: String {
        get { (try? storage.read(String.self, for: key)) ?? "" }
        set { try? storage.save(newValue, for: key) }
    }
}
