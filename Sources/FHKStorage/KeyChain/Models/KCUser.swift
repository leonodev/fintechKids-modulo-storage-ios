//
//  KCUser.swift
//  FHKStorage
//
//  Created by Fredy Leon on 13/12/25.
//

import Foundation

public struct KCUser: Codable, Sendable {
    public let id: String
    public let email: String
    public let lastLogin: Date
    

    public init(id: String, email: String, lastLogin: Date) {
        self.id = id
        self.email = email
        self.lastLogin = lastLogin
    }
}
