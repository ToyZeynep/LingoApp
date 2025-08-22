//
//  LingoAppApp.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI
import Firebase
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        MobileAds.shared.start { status in
            print("AdMob başlatıldı. Status: \(status)")
        }
#if DEBUG
        Analytics.setAnalyticsCollectionEnabled(true)
#endif
        print("AppDelegate: didFinishLaunchingWithOptions tamamlandı")
        return true
    }
}

@main
struct LingoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
