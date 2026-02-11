//
//  FamilyMembers.swift
//  FHKStorage
//
//  Created by Fredy Leon on 31/1/26.
//

import Foundation
import Supabase

public class SupabaseFamilyMembers: SupabasMembersProtocol {
    let supabaseClient: SupabaseClient
    
    let FAMILY_MEMBER_TABLE: String = "fhk_family_members"
    
    public init(supabaseClient: SupabaseClient) {
        self.supabaseClient = supabaseClient
    }
    
    public func addMember(name: String, email: String) async throws {
        let newMember = FamilyMember(email: email, memberName: name)
        
        do {
            let response = try await supabaseClient.from(FAMILY_MEMBER_TABLE)
                .insert(newMember)
                .execute()
            
            print("✅ Status Code: \(response.status)")
            // Si llegas aquí, el servidor recibió algo.
        } catch {
            // Aquí verás errores de red o de decodificación
            print("❌ Error de Supabase: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("Error de decodificación: \(decodingError)")
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
