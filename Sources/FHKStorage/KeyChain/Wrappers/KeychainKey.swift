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
    
    init(_ key: KeychainKey) {
        self.key = key.rawValue
    }
    
    var wrappedValue: T? {
        get { try? KeychainStorage.shared.read(T.self, for: key) }
        set {
            do {
                if let value = newValue {
                    try KeychainStorage.shared.save(value, for: key)
                } else {
                    try KeychainStorage.shared.delete(key)
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
    
    init(_ key: KeychainKey) {
        self.key = key.rawValue
    }
    
    var wrappedValue: String {
        get { (try? KeychainStorage.shared.read(String.self, for: key)) ?? "" }
        set { try? KeychainStorage.shared.save(newValue, for: key) }
    }
}
