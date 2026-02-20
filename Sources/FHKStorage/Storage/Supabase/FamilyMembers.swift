//
//  FamilyMembers.swift
//  FHKStorage
//
//  Created by Fredy Leon on 31/1/26.
//

import Foundation
import Supabase
import FHKUtils

public class SupabaseFamilyMembers: SupabasMembersProtocol {
    let supabaseClient: SupabaseClient
    let FAMILY_MEMBER_TABLE: String = "fhk_family_members"
    
    public init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    public func addMembers(members: [FamilyMember]) async throws {
        
        do {
            let response = try await supabaseClient.from(FAMILY_MEMBER_TABLE)
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
        let members: [FamilyMember] = try await supabaseClient.from(FAMILY_MEMBER_TABLE)
            .select() // Trae todas las columnas
            .execute()
            .value
        
        return members
    }
    
    public func deleteMember(identification: UUID) async throws {
        try await supabaseClient.from(FAMILY_MEMBER_TABLE)
            .delete()
            .eq("identification_uuid", value: identification)
            .execute()
    }
}
