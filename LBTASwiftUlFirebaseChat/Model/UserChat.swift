//
//  UserChat.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 5/31/23.
//

import Foundation
struct ChatUser: Identifiable {
    var id: String { uid }
    
    var uid, email, profileImageUrl: String
    var name = ""
    init(data: [String : Any]) {
        
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
       
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.name = getName(email)
        
    }
    
    init(uid: String, email: String, profileImageUrl: String) {
        
        self.uid = uid
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.name = getName(email)
    }
    
    func getName(_ str: String) -> String {
        guard let indexAt = str.firstIndex(of: "@") else { return "" }
        let value = str.prefix(upTo: indexAt)
        return String(value)
    }
}


