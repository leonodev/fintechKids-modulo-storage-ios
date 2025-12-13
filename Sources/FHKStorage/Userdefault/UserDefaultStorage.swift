// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public actor UserDefaultStorage: UserDefaultsProtocol {
    private let client: UserDefaults
    
    public init(client: UserDefaults = .standard) {
        self.client = client
    }

    public func save<T: Encodable & Sendable>(_ value: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(value)
        self.client.set(data, forKey: key)
    }
    
    public func read<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = self.client.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    public func delete(forKey key: String) async throws {
        self.client.removeObject(forKey: key)
    }
    
    public func update<T: Decodable & Encodable & Sendable>(_ type: T.Type, forKey key: String, update: @Sendable (T?) -> T?) async throws {
        let currentData = self.client.data(forKey: key)
        
        let current: T?
        if let currentData = currentData {
            current = try? JSONDecoder().decode(T.self, from: currentData)
        } else {
            current = nil
        }
        
        guard let updated = update(current) else {
            self.client.removeObject(forKey: key)
            return
        }
        
        let updatedData = try JSONEncoder().encode(updated)
        self.client.set(updatedData, forKey: key)
    }
}



// USO DESDE OTRO MODULO

/*
 
 import FHKStorage
 
 public extension UserDefaultsKeys {
     static let userID = "modulex_user_id"
     static let sessionStartTime = "modulex_start_time"
 }
 
 final class ModuleViewModel: ObservableObject {
     
     // DEPENDENCIA AL PROTOCOLO
     private let storage: UserDefaultsProtocol
     
     // INYECCIÓN DE DEPENDENCIA
     init(storage: UserDefaultsProtocol = UserDefaultStorage()) {
         self.storage = storage
     }
     
     func saveSessionID(id: UUID) async {
         do {
             try await storage.save(id, forKey: UserDefaultsKeys.userID)
         } catch {
             print("Error saving: \(error)")
         }
     }
     
     // ... otros métodos ...
 }
 
 
 TEST UNITARIO
 
 MOCK
 
 // Mock: Simulación en memoria con Diccionario
 final class MockUserDefaultsService: UserDefaultsProtocol {
     
     // Almacén en memoria
     private var store: [String: Data] = [:]
     
     func save<T: Encodable & Sendable>(_ value: T, forKey key: String) async throws {
         // Simplemente guarda como Data simulada
         let data = try JSONEncoder().encode(value)
         store[key] = data
     }
     
     func read<T: Decodable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T? {
         // Lee el Diccionario
         guard let data = store[key] else { return nil }
         return try JSONDecoder().decode(type, from: data)
     }
     
     func update<T: Codable & Sendable>(_ type: T.Type, forKey key: String, update: (T?) -> T?) async throws {
         // Lógica de update simplificada para el Mock
         let currentValue: T? = try await read(type, forKey: key)
         if let updatedValue = update(currentValue) {
             try await save(updatedValue, forKey: key)
         }
     }
     
     func delete(forKey key: String) async throws {
         store.removeValue(forKey: key)
     }
 }
 
 
 TEST
 
 import XCTest
 @testable import ModuleX // Asume que ModuleX tiene el ViewModel
 import FHKStorage

 final class ModuleViewModelTests: XCTestCase {
     
     func test_saveSessionID_shouldCallSaveOnStorage() async throws {
         // Arrange: Inyectar el Mock
         let mock = MockUserDefaultsService()
         let viewModel = ModuleViewModel(storage: mock)
         let testID = UUID()
         
         // Act
         await viewModel.saveSessionID(id: testID)
         
         // Assert: Leer directamente del Mock (in-memory)
         let savedID = try await mock.read(UUID.self, forKey: UserDefaultsKeys.userID)
         XCTAssertEqual(savedID, testID)
     }
 }
 
 */




