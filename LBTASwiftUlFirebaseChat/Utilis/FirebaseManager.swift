//
//  FirebaseManager.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 5/30/23.
//

import Foundation
 import Firebase
import FirebaseStorage

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        //FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init ()
        
    }
    
}
