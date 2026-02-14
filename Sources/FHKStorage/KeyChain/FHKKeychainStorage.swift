//
//  KeychainStorage.swift
//  FHKStorage
//
//  Created by Fredy Leon on 13/12/25.
//

import Security
import Foundation

final public class FHKKeychainStorage: FHKKeychainProtocol {
    private let service = Bundle.main.bundleIdentifier ?? "com.fleon.fintechids"
    private let lock = NSLock()
    
    public init() {}
    
    // MARK: - Public Interface (Thread Safe)
    
    public func save<T: Codable & Sendable>(_ value: T, for key: String, requireBiometry: Bool = false) throws {
        lock.lock()
        defer { lock.unlock() }
        
        let data = try JSONEncoder().encode(value)
        try performSave(data: data, for: key, requireBiometry: requireBiometry)
    }
    
    public func read<T: Decodable & Sendable>(_ type: T.Type, for key: String, prompt: String? = nil) throws -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = try performReadData(for: key, prompt: prompt) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func delete(_ key: String) throws {
        lock.lock()
        defer { lock.unlock() }
        try performDelete(key)
    }
    
    public func contains(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let query = baseQuery(for: key)
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }
    
    public func clearAll() throws {
        lock.lock()
        defer { lock.unlock() }
        for key in KeychainKey.allCases {
            try? performDelete(key.rawValue)
        }
    }
    
    /// Corregido: Ya no causa Deadlock ni error de tipos
    public func atomicUpdate<T: Codable & Sendable>(_ key: String, update: (T?) -> T?) throws {
        lock.lock()
        defer { lock.unlock() }
        
        // 1. Leemos usando el motor interno (sin lock adicional)
        let currentData = try performReadData(for: key)
        let current: T? = if let data = currentData { try? JSONDecoder().decode(T.self, from: data) } else { nil }
        
        // 2. Ejecutamos la lógica de actualización
        if let updated = update(current) {
            let data = try JSONEncoder().encode(updated)
            // 3. Guardamos usando el motor interno (sin biometría por defecto en updates atómicos)
            try performSave(data: data, for: key, requireBiometry: false)
        } else {
            try performDelete(key)
        }
    }
}

// MARK: - Private Engine (The "Perform" methods do NOT use locks)
private extension FHKKeychainStorage {
    
    func performSave(data: Data, for key: String, requireBiometry: Bool) throws {
        var query = baseQuery(for: key)
        
        if requireBiometry {
            if let accessControl = createAccessControl() {
                query.removeValue(forKey: kSecAttrAccessible as String)
                query[kSecAttrAccessControl as String] = accessControl
            }
        }
        
        query[kSecValueData as String] = data
        
        // Limpiamos siempre antes de añadir
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KCError.from(status: status) }
    }
    
    func performReadData(for key: String, prompt: String? = nil) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        if let prompt = prompt {
            query[kSecUseOperationPrompt as String] = prompt
        }
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecSuccess: return item as? Data
        case errSecItemNotFound: return nil
        case errSecUserCanceled: return nil // Usuario canceló FaceID
        default: throw KCError.from(status: status)
        }
    }
    
    func performDelete(_ key: String) throws {
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KCError.from(status: status)
        }
    }
    
    func baseQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
    }
    
    func createAccessControl() -> SecAccessControl? {
        var error: Unmanaged<CFError>?
        return SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryAny,
            &error
        )
    }
}
