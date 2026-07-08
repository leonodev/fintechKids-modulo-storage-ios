
//
//  FHKStorageManager+Test+Preview.swift
//  FHKStorage
//
//  Created by Fredy Leon on 11/2/26.
//

import Foundation
import LocalAuthentication
import FHKDomain
import FHKUtils

extension FHKStorageManager {
    
    public static var test: Self {
        var manager = Self()
        let defaultLanguageData = try? JSONEncoder().encode("EN")
        
        // set language read from user
        manager.readUserDefaultsData = { _ in
            return defaultLanguageData
        }
        
        return manager
        /*
        // You can return an empty `init` object, ready for its properties to be configured.
        return Self()
         */
    }
}
