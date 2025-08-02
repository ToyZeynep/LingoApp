//
//  LingoAppApp.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI
import Firebase

@main
struct LingoAppApp: App {
    
    init() {
        FirebaseApp.configure()
        
    #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(true)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
