//
//  LocalizationManager.swift
//  LingoApp
//
//  Created by Zeynep Toy on 21.08.2025.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = "tr" {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            UserDefaults.standard.synchronize()
            print("🌍 LocalizationManager: Dil değişti -> \(currentLanguage)")
        }
    }
    
    private var bundle: Bundle = Bundle.main
    
    private init() {
        // Başlangıçta kaydedilmiş dili yükle
        currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "tr"
        setLanguage(currentLanguage)
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("❌ Dil dosyası bulunamadı: \(language)")
            self.bundle = Bundle.main
            return
        }
        
        self.bundle = bundle
        print("✅ Dil değiştirildi: \(language)")
        
        // Notification gönder (isteğe bağlı)
        NotificationCenter.default.post(name: .languageChanged, object: language)
    }
    
    func localizedString(for key: String) -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
