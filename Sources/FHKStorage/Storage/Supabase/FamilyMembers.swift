//
//  FamilyMembers.swift
//  FHKStorage
//
//  Created by Fredy Leon on 31/1/26.
//

import Foundation
import Supabase
import FHKUtils

public final class SupabaseFamilyMembers: SupabasMembersProtocol {
    let supabaseClient: SupabaseClient
    
    public init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    public func addMembers(members: [FamilyMember]) async throws {
        
        do {
            let response = try await supabaseClient.from(DB.SUPABASE.TABLE_FAMILY_MEMBER.NAME)
                .insert(members)
                .execute()
            
            Logger.info("Status Code: \(response.status)")
        } catch {
            Logger.error("Error de Supabase: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                Logger.error("Error de decodificación: \(decodingError)")
            }
        }
    }
    
    public func fetchFamilyMembers() async throws -> [FamilyMember] {
        let members: [FamilyMember] = try await supabaseClient.from(DB.SUPABASE.TABLE_FAMILY_MEMBER.NAME)
            .select() // Trae todas las columnas
            .execute()
            .value
        
        return members
    }
    
    public func deleteMember(identification: UUID) async throws {
        try await supabaseClient.from(DB.SUPABASE.TABLE_FAMILY_MEMBER.NAME)
            .delete()
            .eq(DB.SUPABASE.TABLE_FAMILY_MEMBER.COLUMN.identificationUUID, value: identification)
            .execute()
    }
}
