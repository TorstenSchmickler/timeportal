//
//  userDefaultsService.swift
//  TimePortal
//
//  Created by Torsten Schmickler on 02/06/2018.
//  Copyright © 2018 Torsten Schmickler. All rights reserved.
//

import Foundation

class UserDefaultsService {
    let defaults = UserDefaults.standard
    
    func setValue(with Name: String, value: Any) {
        defaults.set(value, forKey: Name)
    }
    
    func getValue(with name: String, of type: String) -> Any? {
        switch type {
        case "Bool":
            return defaults.bool(forKey: name)
        case "String":
            let stringValue = defaults.string(forKey: name)
            return stringValue ?? nil
        default:
            return  defaults.string(forKey: name)
        }
    }
}
