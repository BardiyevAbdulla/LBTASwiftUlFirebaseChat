//
//  RecentMessage.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 6/2/23.
//

import Foundation
import Firebase


struct RecentMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let text, fromId, toId: String
    let email, profileImageUrl: String
    let timestamp: Timestamp
    
    init(doc: String, data: [String : Any]) {
        self.documentId = doc
        self.text = data[FirebaseConstant.text] as? String ?? ""
        self.fromId = data[FirebaseConstant.fromId] as? String ?? ""
        self.toId = data[FirebaseConstant.toId] as? String ?? ""
        self.email = data[FirebaseConstant.email] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstant.profileImageUrl] as? String ?? ""
        self.timestamp = data[FirebaseConstant.timestamp] as? Timestamp ?? Timestamp()
    }
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self.timestamp.dateValue(), relativeTo: Date ())
        
    }
}
