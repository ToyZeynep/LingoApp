//
//  LingoAppApp.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct LingoAppApp: App {
    
    init() {
        MobileAds.shared.start { status in
            print("AdMob başlatıldı. Status: \(status)")
        }
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
