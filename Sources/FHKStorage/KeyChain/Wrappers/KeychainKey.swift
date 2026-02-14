//
//  KeychainKey.swift
//  FHKStorage
//
//  Created by Fredy Leon on 13/12/25.
//

import Foundation
import FHKUtils

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
    private let requireBiometry: Bool
    
    init(_ key: KeychainKey, storage: FHKKeychainProtocol, requireBiometry: Bool = false) {
        self.key = key.rawValue
        self.storage = storage
        self.requireBiometry = requireBiometry
    }
    
    var wrappedValue: T? {
        get {
            // Para lectura general desde un wrapper, solemos no pasar prompt
            // a menos que sea un dato que SIEMPRE requiera la cara al leerse.
            try? storage.read(T.self, for: key, prompt: nil)
        }
        set {
            do {
                if let value = newValue {
                    // Usamos el flag configurado en el init
                    try storage.save(value, for: key, requireBiometry: requireBiometry)
                } else {
                    try storage.delete(key)
                }
            } catch {
                Logger.error("🔐 Keychain error: \(error)")
            }
        }
    }
}

@propertyWrapper
struct KeychainString: Sendable {
    private let key: String
    private let storage: FHKKeychainProtocol
    private let requireBiometry: Bool
    
    init(_ key: KeychainKey, storage: FHKKeychainProtocol, requireBiometry: Bool = false) {
        self.key = key.rawValue
        self.storage = storage
        self.requireBiometry = requireBiometry
    }
    
    var wrappedValue: String {
        get { (try? storage.read(String.self, for: key, prompt: nil)) ?? "" }
        set {
            try? storage.save(newValue, for: key, requireBiometry: requireBiometry)
        }
    }
}
