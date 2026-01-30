//
//  square_gameApp.swift
//  square_game
//
//  Created by COBSCCOMP24.2P-008 on 2026-01-10.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct square_gameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            if firebaseManager.isAuthenticated {
                ContentView()
                    .environmentObject(firebaseManager)
            } else {
                AuthenticationView()
                    .environmentObject(firebaseManager)
            }
        }
    }
}
