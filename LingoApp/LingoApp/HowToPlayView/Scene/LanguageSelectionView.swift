//
//  LanguageSelectionView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 20.08.2025.
//

import SwiftUI

struct LanguageSelectionView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "tr"
    @AppStorage("hasSelectedLanguage") private var hasSelectedLanguage: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var onLanguageSelected: ((String) -> Void)?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Logo ve başlık
                VStack(spacing: 16) {
                    Image(systemName: "globe")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.cyan)
                    
                    Text("Dil Seçimi".localized)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Hangi dilde oynamak istiyorsun?".localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 60)
                
                // Dil seçenekleri
                VStack(spacing: 16) {
                    // Türkçe seçeneği
                    LanguageOptionCard(
                        flag: "🇹🇷",
                        title: "Türkçe",
                        subtitle: "Turkish",
                        description: "Ana dilinizde kelime oyunu",
                        isSelected: selectedLanguage == "tr"
                    ) {
                        selectLanguage("tr")
                    }
                    
                    // İngilizce seçeneği
                    LanguageOptionCard(
                        flag: "🇺🇸",
                        title: "English",
                        subtitle: "İngilizce",
                        description: "Play word game in English",
                        isSelected: selectedLanguage == "en"
                    ) {
                        selectLanguage("en")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Devam butonu
                Button(action: {
                    confirmLanguageSelection()
                }) {
                    HStack {
                        Text("Devam Et".localized)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                
                // İlk açılışta atla butonu
                if !hasSelectedLanguage {
                    Button("Telefon Dilimi Kullan".localized) {
                        skipLanguageSelection()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            if !hasSelectedLanguage {
                let systemLanguage = getSystemLanguage()
                selectedLanguage = systemLanguage
                print("📱 İlk açılış: Sistem dili otomatik seçildi -> \(systemLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English")")
            }
            
            // Eğer daha önce seçim yapılmışsa, mevcut seçimi vurgula
            if hasSelectedLanguage {
                print("🌍 Mevcut dil seçimi: \(selectedLanguage)")
            }
        }
    }
    
    private func selectLanguage(_ languageCode: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedLanguage = languageCode
        }
    }
    
    private func confirmLanguageSelection() {
        hasSelectedLanguage = true
        
        // Dil ayarlarını sistem genelinde uygula
        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Callback çağır
        onLanguageSelected?(selectedLanguage)
        
        // Başarı sesi
        SoundEngine.shared.play(.success)
        
        // View'ı kapat
        dismiss()
        
        print("✅ Dil ayarı kaydedildi: \(selectedLanguage)")
    }
    
    private func skipLanguageSelection() {
        // Telefonun sistem dilini al
        let systemLanguage = getSystemLanguage()
        selectedLanguage = systemLanguage
        hasSelectedLanguage = true
        
        // Dil ayarlarını sistem genelinde uygula
        UserDefaults.standard.set([systemLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        dismiss()
        
        let languageDisplay = systemLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English"
        print("⏭️ Dil seçimi atlandı, telefon dili alındı: \(languageDisplay)")
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
        
        // Varsayılan olarak İngilizce
        print("📱 Sistem dili desteklenmiyor, varsayılan: İngilizce")
        return "en"
    }
}

// MARK: - Language Option Card Component
struct LanguageOptionCard: View {
    let flag: String
    let title: String
    let subtitle: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag emoji
                Text(flag)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Seçim göstergesi
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(.cyan)
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? .cyan : .white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tutorial Page için Language Support
extension TutorialPage {
    static func createLocalizedPages() -> [TutorialPage] {
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "tr"
        
        if language == "en" {
            return [
                TutorialPage(
                    title: "Welcome to Lingo!",
                    description: "Ready to guess the secret word? Let's learn the basic rules.",
                    icon: "gamecontroller.fill",
                    content: .basicRules
                ),
                TutorialPage(
                    title: "Color Codes",
                    description: "Each letter color gives you a clue. Interpret the colors correctly!",
                    icon: "paintpalette.fill",
                    content: .letterColors
                ),
                TutorialPage(
                    title: "Jokers",
                    description: "When you're stuck, jokers will help you. Use them wisely!",
                    icon: "star.fill",
                    content: .jokers
                ),
                TutorialPage(
                    title: "Difficulty Levels",
                    description: "Choose the difficulty that suits your level and start the challenge!",
                    icon: "target",
                    content: .difficultyLevels
                ),
                TutorialPage(
                    title: "Tips",
                    description: "You can be more successful with these tactics!",
                    icon: "lightbulb.fill",
                    content: .tips
                )
            ]
        } else {
            return [
                TutorialPage(
                    title: "Lingo'ya Hoş Geldin!",
                    description: "Gizli kelimeyi tahmin etmeye hazır mısın? Temel kuralları öğrenelim.",
                    icon: "gamecontroller.fill",
                    content: .basicRules
                ),
                TutorialPage(
                    title: "Renk Kodları",
                    description: "Her harf rengi sana ipucu verir. Renkleri doğru yorumla!",
                    icon: "paintpalette.fill",
                    content: .letterColors
                ),
                TutorialPage(
                    title: "Jokerler",
                    description: "Zorlandığında jokerler sana yardım edecek. Akıllıca kullan!",
                    icon: "star.fill",
                    content: .jokers
                ),
                TutorialPage(
                    title: "Zorluk Seviyeleri",
                    description: "Kendi seviyene uygun zorluğu seç ve meydan okumaya başla!",
                    icon: "target",
                    content: .difficultyLevels
                ),
                TutorialPage(
                    title: "İpuçları",
                    description: "Bu taktiklerle daha başarılı olabilirsin!",
                    icon: "lightbulb.fill",
                    content: .tips
                )
            ]
        }
    }
}

struct UpdatedHowToPlayView: View {
    var onDismiss: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "tr"
    
    private var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: "HasSeenTutorial")
    }
    
    // Dil bazlı tutorial sayfaları
    private var tutorialPages: [TutorialPage] {
        TutorialPage.createLocalizedPages()
    }
    
    private func dismissView() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TabView(selection: $currentPage) {
                        ForEach(0..<tutorialPages.count, id: \.self) { index in
                            TutorialPageView(page: tutorialPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 8) {
                            ForEach(0..<tutorialPages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? .cyan : .white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        
                        HStack {
                            if currentPage > 0 {
                                Button("Geri".localized) {
                                    withAnimation {
                                        currentPage -= 1
                                    }
                                }
                                .foregroundColor(.cyan)
                                .font(.system(size: 16, weight: .medium))
                            }
                            
                            Spacer()
                            
                            if currentPage < tutorialPages.count - 1 {
                                Button("İleri".localized) {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                }
                                .foregroundColor(.cyan)
                                .font(.system(size: 16, weight: .medium))
                            } else {
                                Button("Başla!".localized) {
                                    UserDefaults.standard.set(true, forKey: "HasSeenTutorial")
                                    dismissView()
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Nasıl Oynanır".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    dismissView()
                }) {
                    Text(isFirstLaunch ? "Atla".localized : "Kapat".localized)
                        .foregroundColor(.cyan)
                        .font(.system(size: 16, weight: .semibold))
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - App Launch Flow Manager
class AppLaunchManager: ObservableObject {
    @Published var showLanguageSelection = false
    @Published var showTutorial = false
    @Published var isReady = false
    
    @AppStorage("hasSelectedLanguage") private var hasSelectedLanguage: Bool = false
    @AppStorage("HasSeenTutorial") private var hasSeenTutorial: Bool = false
    
    func checkLaunchFlow() {
        if !hasSelectedLanguage {
            // İlk: Dil seçimi
            showLanguageSelection = true
        } else if !hasSeenTutorial {
            // İkinci: Tutorial
            showTutorial = true
        } else {
            // Üçüncü: Ana uygulamaya geç
            isReady = true
        }
    }
    
    func onLanguageSelected() {
        hasSelectedLanguage = true
        showLanguageSelection = false
        
        // Dil seçildikten sonra tutorial göster
        if !hasSeenTutorial {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showTutorial = true
            }
        } else {
            isReady = true
        }
    }
    
    func onTutorialCompleted() {
        hasSeenTutorial = true
        showTutorial = false
        isReady = true
    }
}
