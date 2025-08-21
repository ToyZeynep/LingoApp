//
//  SettingsView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 10.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var soundEnabled: Bool
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "tr"
    
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
                
                VStack(spacing: 30) {
                    Text("Ayarlar".localized)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                                .frame(width: 30)
                            
                            Text("Ses Efektleri".localized)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Toggle("", isOn: $soundEnabled)
                                .scaleEffect(0.8)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Dil Seçimi
                        HStack {
                            Image(systemName: "globe")
                                .font(.title2)
                                .foregroundColor(.cyan)
                                .frame(width: 30)
                            
                            Text("Dil".localized)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Menu {
                                Button {
                                    changeLanguage(to: "tr")
                                } label: {
                                    HStack {
                                        Text("🇹🇷 Türkçe")
                                        if selectedLanguage == "tr" {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                
                                Button {
                                    changeLanguage(to: "en")
                                } label: {
                                    HStack {
                                        Text("🇺🇸 English")
                                        if selectedLanguage == "en" {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(selectedLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam".localized) {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            let v = UserDefaults.standard.object(forKey: "SoundEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "SoundEnabled")
            soundEnabled = v
        }
        .onChange(of: soundEnabled) { newValue in
            UserDefaults.standard.set(newValue, forKey: "SoundEnabled")
            SoundEngine.shared.enabled = newValue
        }
        // AppStorage otomatik algılar, notification gerekmez
    }
    
    private func changeLanguage(to languageCode: String) {
        // Eski dili kaydet
        let oldLanguage = selectedLanguage
        
        // Yeni dili ayarla
        selectedLanguage = languageCode
        
        // App'in dilini değiştirmek için
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Ses efekti
        SoundEngine.shared.play(.click)
        
        let languageDisplay = languageCode == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English"
        print("🌍 Dil değiştirildi: \(oldLanguage) → \(languageCode) (\(languageDisplay))")
        
        // Kullanıcıya bilgi ver (opsiyonel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let alert = UIAlertController(
                    title: "language_change_title".localized,
                    message: "language_change_message".localized,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Tamam".localized, style: .default))
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
}
