//
//  ChatMessage.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 6/1/23.
//

import Foundation

struct ChatMessage: Identifiable {
    var id: String { docId}
    let docId: String
    let fromId, toId, text: String
    
    init (docId: String, data: [String: Any]) {
        self.docId = docId
        self.fromId = data[FirebaseConstant.fromId] as? String ?? ""
        self.toId = data[FirebaseConstant.toId] as? String ?? ""
        self.text = data[FirebaseConstant.text] as? String ?? ""
                      
        }
}
