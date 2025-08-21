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
    @State private var showLanguageSelection = false
    @State private var isFirstDayReward: Bool = false
    @State private var showDailyReward = false
    @State private var dailyRewardType: JokerType? = nil
    @State private var dailyRewardCount: Int = 0
    @AppStorage("hasSelectedLanguage") private var hasSelectedLanguage: Bool = false
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    enum NavigationState: Equatable {
        case home
        case difficultySelection
        case game(DifficultyLevel)
    }
    
    var body: some View {
        Group {
            if showLanguageSelection {
                LanguageSelectionView { language in
                    localizationManager.setLanguage(language)
                    hasSelectedLanguage = true
                    showLanguageSelection = false
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
                    .onAppear {
                           if hasSelectedLanguage && hasSeenTutorial {
                               let tempManager = JokerManager()
                               if let reward = DailyRewardManager().claimIfNeeded(jokerManager: tempManager) {
                                      dailyRewardType = reward.jokerType
                                      dailyRewardCount = reward.count
                                      isFirstDayReward = reward.isFirstDay
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                       showDailyReward = true
                                   }
                               }
                           }
                       }
                    
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
        .onChange(of: localizationManager.currentLanguage) { newLanguage in
            print("🌍 ContentView: Dil değişikliği algılandı -> \(newLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English")")
        }
        .overlay {
            if showDailyReward {
                CustomAlertView(
                    title: "daily_reward_title".localized,
                    message: isFirstDayReward
                        ? "first_day_reward_message".localized
                        : String(format: "daily_reward_message".localized, dailyRewardCount, dailyRewardType?.title ?? ""),
                    primaryButtonTitle: "Harika!".localized,
                    primaryAction: {},
                    icon: "gift.fill",
                    iconColor: isFirstDayReward ? .purple : (dailyRewardType?.brightColor ?? .blue),
                    isPresented: $showDailyReward
                )
            }
        }
    }
    
    // MARK: - App Initialization
    
    private func initializeApp() async {
        if UserDefaults.standard.object(forKey: "SoundEnabled") == nil {
            soundEnabled = true
            UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
        }
        
        await MainActor.run {
            checkLaunchFlow()
        }
    }
    
    private func checkLaunchFlow() {
        print("🚀 Uygulama başlatılıyor...")
        
        if !hasSelectedLanguage {
            print("🌍 İlk açılış: Dil seçimi gerekli")
            autoDetectSystemLanguage()
            showLanguageSelection = true
        }
        else if !hasSeenTutorial {
            print("📖 Tutorial gerekli")
            showTutorial = true
        }
        else {
            print("✅ Uygulama hazır - Ana ekran gösteriliyor")
        }
    }
    
    private func autoDetectSystemLanguage() {
        let systemLanguage = getSystemLanguage()
        localizationManager.setLanguage(systemLanguage)
        
        let languageDisplay = systemLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English"
        print("📱 Sistem dili otomatik algılandı: \(languageDisplay)")
    }
    
    private func checkTutorialAfterLanguage() {
        if !hasSeenTutorial {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showTutorial = true
            }
        }
    }
    
    private func getSystemLanguage() -> String {
        let preferredLanguages = Locale.preferredLanguages
        let systemLanguageCode = preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
        
        let supportedLanguages = ["tr", "en"]
        
        if supportedLanguages.contains(systemLanguageCode) {
            print("📱 Sistem dili tespit edildi: \(systemLanguageCode)")
            return systemLanguageCode
        }
        
        if systemLanguageCode.hasPrefix("tr") ||
           Locale.current.regionCode == "TR" {
            print("📱 Türkçe locale tespit edildi")
            return "tr"
        }
        
        if Locale.current.regionCode == "TR" {
            print("📱 Türkiye bölgesi tespit edildi, Türkçe seçiliyor")
            return "tr"
        }
        
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
