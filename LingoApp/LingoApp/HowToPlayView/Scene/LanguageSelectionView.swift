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

        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        onLanguageSelected?(selectedLanguage)

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
