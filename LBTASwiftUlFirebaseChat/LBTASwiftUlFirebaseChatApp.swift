//
//  LBTASwiftUlFirebaseChatApp.swift
//  LBTASwiftUlFirebaseChat
//
//  Created by admin on 5/29/23.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func  application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey :
    Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        return true
    }
}


@main
struct LBTASwiftUlFirebaseChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainMessagesView()
           
        }
    }
}
