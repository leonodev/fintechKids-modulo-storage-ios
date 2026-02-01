//
//  StorageProtocol.swift
//  FHKStorage
//
//  Created by Fredy Leon on 1/2/26.
//

import Foundation

public protocol StorageProtocol {
    func addMember(name: String, email: String) async throws
    func fetchFamilyMembers() async throws -> [FamilyMember]
    func deleteMember(identification: UUID) async throws
}
