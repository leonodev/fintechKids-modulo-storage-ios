//
//  FamilyMember.swift
//  FHKStorage
//
//  Created by Fredy Leon on 1/2/26.
//

import Foundation
import FHKDesignSystem

public struct FamilyMember: Codable, Identifiable, Hashable, Equatable {
    // Identificador de Supabase (Opcional para nuevos registros)
    public var id: Int?
    
    // Propiedades que unicamente seran persisitdas
    public let email_parent: String
    public let member_name: String
    
    // Propiedades de conveniencia para la UI (No se guardan en la DB)
    public var avatarImage: String?
    public var iconName: String = ImageSystem.trash.name
    
    public init(id: Int? = nil,
                email: String,
                memberName: String,
                avatarImage: String? = AvatarType.boy_9.name
    ) {
        self.id = id
        self.email_parent = email
        self.member_name = memberName
        self.avatarImage = avatarImage
    }
    
    // ignoreamos avatarImage e iconName al guardar en DB
    enum CodingKeys: String, CodingKey {
        case id
        case email_parent
        case member_name
    }
}
