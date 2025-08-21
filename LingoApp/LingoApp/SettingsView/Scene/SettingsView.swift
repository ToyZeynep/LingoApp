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
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
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
                                        if localizationManager.currentLanguage == "tr" {
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
                                        if localizationManager.currentLanguage == "en" {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(localizationManager.currentLanguage == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English")
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
                
                // Toast mesajı
                if showToast {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            
                            Text(toastMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThickMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.green.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    }
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
    }
    
    private func changeLanguage(to languageCode: String) {
        // Eski dili kaydet
        let oldLanguage = localizationManager.currentLanguage
        
        // Aynı dil seçildiyse hiçbir şey yapma
        guard oldLanguage != languageCode else { return }
        
        // Yeni dili ayarla - LocalizationManager otomatik UI'ı güncelleyecek
        localizationManager.setLanguage(languageCode)
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Ses efekti
        SoundEngine.shared.play(.click)
        
        let languageDisplay = languageCode == "tr" ? "🇹🇷 Türkçe" : "🇺🇸 English"
        print("🌍 Dil değiştirildi: \(oldLanguage) → \(languageCode) (\(languageDisplay))")
        
        // Toast mesajını göster
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let message = languageCode == "tr" ?
                "Dil Türkçe olarak değiştirildi" :
                "Language changed to English"
            
            toastMessage = message
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showToast = true
            }
            
            // Toast'ı 2.5 saniye sonra gizle
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showToast = false
                }
            }
        }
    }
}
