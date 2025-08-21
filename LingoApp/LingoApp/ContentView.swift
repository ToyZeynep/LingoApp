//
//  ContentView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var navigationState: NavigationState = .home
    @State private var selectedDifficulty: DifficultyLevel? = nil
    @State private var soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
    @State private var showTutorial = false
    @State private var hasSeenTutorial = UserDefaults.standard.bool(forKey: "HasSeenTutorial")
    
    // Dil seçimi için state'ler
    @AppStorage("hasSelectedLanguage") private var hasSelectedLanguage: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "tr"
    @State private var showLanguageSelection = false
    
    enum NavigationState: Equatable {
        case home
        case difficultySelection
        case game(DifficultyLevel)
    }
    
    var body: some View {
        Group {
            if showLanguageSelection {
                LanguageSelectionView { language in
                    selectedLanguage = language
                    hasSelectedLanguage = true
                    showLanguageSelection = false
                    
                    // Dil seçildikten sonra tutorial kontrol et
                    checkTutorialAfterLanguage()
                }
            } else if showTutorial {
                HowToPlayView(onDismiss: {
                    hasSeenTutorial = true
                    UserDefaults.standard.set(true, forKey: "HasSeenTutorial")
                    showTutorial = false
                })
            } else {
                switch navigationState {
                case .home:
                    HomeScreenView(soundEnabled: $soundEnabled) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            navigationState = .difficultySelection
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                    
                case .difficultySelection:
                    DifficultySelectionView(
                        selectedDifficulty: $selectedDifficulty,
                        onBack: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                navigationState = .home
                                selectedDifficulty = nil
                            }
                        }
                    )
                    .task(id: selectedDifficulty) {
                        if let difficulty = selectedDifficulty {
                            try? await Task.sleep(nanoseconds: 200_000_000)
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                navigationState = .game(difficulty)
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    
                case .game(let difficulty):
                    GameView(
                        difficulty: difficulty,
                        soundEnabled: $soundEnabled
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            navigationState = .difficultySelection
                            selectedDifficulty = nil
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .interactiveDismissDisabled()
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: navigationState)
        .preferredColorScheme(.dark)
        .statusBarHidden(navigationState == .game(selectedDifficulty ?? .easy))
        .task {
            await initializeApp()
        }
        .onChange(of: selectedLanguage) { newLanguage in
            // Dil değiştiğinde log yap (GameModel'ler AppStorage ile otomatik algılar)
            print("🌍 ContentView: Dil değişikliği -> \(newLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English")")
        }
    }
    
    // MARK: - App Initialization
    
    private func initializeApp() async {
        // Ses ayarlarını kontrol et
        if UserDefaults.standard.object(forKey: "SoundEnabled") == nil {
            soundEnabled = true
            UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
        }
        
        // Dil ve tutorial akışını kontrol et
        await MainActor.run {
            checkLaunchFlow()
        }
    }
    
    private func checkLaunchFlow() {
        print("🚀 Uygulama başlatılıyor...")
        
        // İlk: Dil seçimi kontrolü
        if !hasSelectedLanguage {
            print("🌍 İlk açılış: Dil seçimi gerekli")
            // Sistem dilini otomatik algıla
            autoDetectSystemLanguage()
            showLanguageSelection = true
        }
        // İkinci: Tutorial kontrolü
        else if !hasSeenTutorial {
            print("📖 Tutorial gerekli")
            showTutorial = true
        }
        // Üçüncü: Ana uygulamaya geç
        else {
            print("✅ Uygulama hazır - Ana ekran gösteriliyor")
        }
    }
    
    private func autoDetectSystemLanguage() {
        let systemLanguage = getSystemLanguage()
        selectedLanguage = systemLanguage
        
        let languageDisplay = systemLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English"
        print("📱 Sistem dili otomatik algılandı: \(languageDisplay)")
    }
    
    private func checkTutorialAfterLanguage() {
        // Dil seçildikten sonra tutorial kontrol et
        if !hasSeenTutorial {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showTutorial = true
            }
        }
    }
    
    /// Telefonun sistem dilini kontrol eder (iOS 15+ uyumlu)
    private func getSystemLanguage() -> String {
        // iOS 15 uyumlu sistem dili algılama
        let preferredLanguages = Locale.preferredLanguages
        let systemLanguageCode = preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        
        // Desteklenen dilleri kontrol et
        let supportedLanguages = ["tr", "en"]
        
        // Sistem dili destekleniyorsa onu kullan
        if supportedLanguages.contains(systemLanguageCode) {
            print("📱 Sistem dili tespit edildi: \(systemLanguageCode)")
            return systemLanguageCode
        }
        
        // Türkçe locale kontrolü (tr-TR, tr-CY vs.)
        if systemLanguageCode.hasPrefix("tr") ||
           Locale.current.regionCode == "TR" {
            print("📱 Türkçe locale tespit edildi")
            return "tr"
        }
        
        // Arapça, Kürtçe vs. Türkiye bölgesindeki diller
        if Locale.current.regionCode == "TR" {
            print("📱 Türkiye bölgesi tespit edildi, Türkçe seçiliyor")
            return "tr"
        }
        
        // Varsayılan olarak İngilizce
        print("📱 Sistem dili desteklenmiyor, varsayılan: İngilizce")
        return "en"
    }
}

// MARK: - Language Change Notification Support
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13")
            .previewDisplayName("iPhone 13")
        
        ContentView()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
            .previewDisplayName("iPad Pro")
            .environment(\.locale, .init(identifier: "tr"))
        
        ContentView()
            .previewDevice("iPhone 13")
            .previewDisplayName("English iPhone")
            .environment(\.locale, .init(identifier: "en"))
    }
}

// MARK: - Usage Documentation
/*
Bu ContentView şimdi şu akışı takip eder:

📱 UYGULAMA BAŞLANGICI:
1. Sistem dili otomatik algılanır
2. İlk açılışta dil seçimi ekranı gösterilir (sistem dili önceden seçili)
3. Kullanıcı isterse farklı dil seçer veya "Telefon Dilimi Kullan" der
4. Dil ayarlandıktan sonra tutorial gösterilir (seçilen dilde)
5. Ana uygulamaya geçiş

🔄 SONRAKI AÇILIŞLAR:
- Direkt ana uygulamaya geçer
- Önceden seçilen dilde çalışır

🌍 DIL DEĞİŞİKLİĞİ:
- Settings'ten manuel değiştirilebilir
- Tüm GameModel'ler otomatik güncellenir
- Notification sistemi ile senkronize olur

📊 SİSTEM DİLİ ALGILAMASI:
- Türkçe iPhone → Türkçe
- İngilizce iPhone → İngilizce
- Türkiye'deki diğer diller → Türkçe
- Desteklenmeyen diller → İngilizce
*/
