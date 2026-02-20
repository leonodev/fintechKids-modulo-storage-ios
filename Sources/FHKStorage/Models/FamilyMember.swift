//
//  FamilyMember.swift
//  FHKStorage
//
//  Created by Fredy Leon on 1/2/26.
//

import Foundation

public struct FamilyMember: Codable, Identifiable, Hashable, Equatable {
    // Identificador de Supabase (Opcional para nuevos registros)
    public var id: Int?
    public let email: String
    public let memberName: String
    
    // Propiedades de conveniencia para la UI (No se guardan en la DB)
    public var avatarImage: String = "boy_9"
    public var iconName: String = "trash"
    
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
