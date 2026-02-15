//
//  KeychainProtocol.swift
//  FHKStorage
//
//  Created by Fredy Leon on 13/12/25.
//

import Security
import Foundation

public protocol FHKKeychainProtocol: Sendable {
    func save<T: Codable & Sendable>(_ value: T,
                                     for key: String,
                                     requireBiometry: Bool) throws
    func read<T: Decodable & Sendable>(_ type: T.Type,
                                        for key: String,
                                        prompt: String?) throws -> T?
    func delete(_ key: String) throws
    func contains(_ key: String) -> Bool
    func clearAll() throws
}

public struct KeychainKeys {
    private init() {}
}
