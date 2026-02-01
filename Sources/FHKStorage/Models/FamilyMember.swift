//
//  FamilyMember.swift
//  FHKStorage
//
//  Created by Fredy Leon on 1/2/26.
//

import Foundation

public struct FamilyMember: Codable, Identifiable {
    public var id: Int? // Supabase suele generar un ID automático
    let email: String
    let memberName: String
    
    public init(id: Int? = nil, email: String, memberName: String) {
        self.id = id
        self.email = email
        self.memberName = memberName
    }

    // Mapeamos los nombres de Swift (camelCase) a los de SQL (snake_case)
    enum CodingKeys: String, CodingKey {
        case id
        case email = "email_parent"
        case memberName = "member_name"
    }
}
