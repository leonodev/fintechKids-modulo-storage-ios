//
//  DB.swift
//  FHKStorage
//
//  Created by Fredy Leon on 21/2/26.
//

import Functions

public struct DB {
    
    public struct SUPABASE {
        
        public struct TABLE_FAMILY_MEMBER {
            public static let NAME: String = "fhk_family_members"

            public struct COLUMN {
                public static let email = "email_parent"
                public static let memberName = "member_name"
                public static let avatarName = "avatar_name"
                public static let identificationUUID = "identification_uuid"
            } 
        }
    }
}
