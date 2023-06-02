//
//  UserDefault.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 6/2/23.
//

import Foundation

class StoragePhone {
    let token = "token"
    let standard = UserDefaults.standard
    
    static let shared = StoragePhone()
    func setToken(_ token: String) {
        standard.setValue(token, forKey: self.token)
    }
    
    func getToken() -> String? {
        return standard.string(forKey: token)
    }
}
