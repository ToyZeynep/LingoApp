//
//  CustomAlertView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 10.08.2025.
//


//
//  CustomAlertView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

// MARK: - Custom Alert View
struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    var secondaryButtonTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil
    var icon: String? = nil
    var iconColor: Color = .cyan
    
    @Binding var isPresented: Bool
    @State private var appear = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Arka plan blur ve karartma
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                    // Dışarı tıklanınca kapatma (opsiyonel)
                    // dismissAlert()
                }
            
            // Alert içeriği
            VStack(spacing: 0) {
                // İkon ve başlık
                VStack(spacing: 15) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 45))
                            .foregroundColor(iconColor)
                            .shadow(color: iconColor.opacity(0.5), radius: 10)
                            .scaleEffect(appear ? 1.0 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appear)
                    }
                    
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 25)
                .padding(.horizontal, 20)
                
                // Mesaj
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
                // Butonlar
                VStack(spacing: 12) {
                    // Primary buton
                    Button(action: {
                        primaryAction()
                        dismissAlert()
                    }) {
                        Text(primaryButtonTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [.cyan, .cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    // Secondary buton (opsiyonel)
                    if let secondaryTitle = secondaryButtonTitle {
                        Button(action: {
                            secondaryAction?()
                            dismissAlert()
                        }) {
                            Text(secondaryTitle)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.15, blue: 0.3),
                                Color(red: 0.05, green: 0.1, blue: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 15)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
                appear = true
            }
        }
    }
    
    private func dismissAlert() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.9
            opacity = 0
            appear = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}

// MARK: - Alert Tipleri
enum AlertType {
    case success
    case error
    case warning
    case info
    case reward
    case gameOver
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .reward: return "gift.fill"
        case .gameOver: return "gamecontroller.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .cyan
        case .reward: return .yellow
        case .gameOver: return .purple
        }
    }
}

// MARK: - Kullanım için View Extension
extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        type: AlertType = .info,
        title: String,
        message: String,
        primaryButtonTitle: String = "Tamam",
        primaryAction: @escaping () -> Void = {},
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                CustomAlertView(
                    title: title,
                    message: message,
                    primaryButtonTitle: primaryButtonTitle,
                    primaryAction: primaryAction,
                    secondaryButtonTitle: secondaryButtonTitle,
                    secondaryAction: secondaryAction,
                    icon: type.icon,
                    iconColor: type.color,
                    isPresented: isPresented
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

// MARK: - Özel Alert Varyasyonları

// Oyun kazanma alert'i
struct GameWonAlert: View {
    @Binding var isPresented: Bool
    let word: String
    let guessCount: Int
    let onNewGame: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        CustomAlertView(
            title: "Tebrikler! 🎉",
            message: "Kelimeyi \(guessCount) tahminde buldun!\n\nDoğru kelime: \(word)",
            primaryButtonTitle: "Yeni Oyun",
            primaryAction: onNewGame,
            secondaryButtonTitle: "Çıkış",
            secondaryAction: onExit,
            icon: "trophy.fill",
            iconColor: .yellow,
            isPresented: $isPresented
        )
    }
}

// Joker ödül alert'i
struct JokerRewardAlert: View {
    @Binding var isPresented: Bool
    let jokerType: JokerType
    let count: Int
    let totalCorrect: Int
    let nextRewardIn: Int
    
    var body: some View {
        CustomAlertView(
            title: "Joker Kazandın! 🎁",
            message: """
            \(totalCorrect). doğru tahminin için
            \(count) adet \(jokerType.title) kazandın!
            
            Sonraki ödül için \(nextRewardIn) doğru tahmin daha!
            """,
            primaryButtonTitle: "Harika!",
            primaryAction: {},
            icon: "gift.fill",
            iconColor: jokerType.brightColor,
            isPresented: $isPresented
        )
    }
}

// MARK: - Kullanım Örneği
struct ContentViewExample: View {
    @State private var showAlert = false
    @State private var showGameWonAlert = false
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Başarı Alert") {
                showAlert = true
            }
            
            Button("Oyun Kazandın Alert") {
                showGameWonAlert = true
            }
            
            Button("Hata Alert") {
                showErrorAlert = true
            }
        }
        .customAlert(
            isPresented: $showAlert,
            type: .success,
            title: "Başarılı!",
            message: "İşlem başarıyla tamamlandı.",
            primaryButtonTitle: "Tamam"
        )
        .customAlert(
            isPresented: $showGameWonAlert,
            type: .gameOver,
            title: "Oyun Bitti!",
            message: "Harika bir oyundu!",
            primaryButtonTitle: "Yeni Oyun",
            primaryAction: { print("Yeni oyun") },
            secondaryButtonTitle: "Çıkış",
            secondaryAction: { print("Çıkış") }
        )
        .customAlert(
            isPresented: $showErrorAlert,
            type: .error,
            title: "Hata!",
            message: "Bir şeyler ters gitti.",
            primaryButtonTitle: "Tekrar Dene",
            secondaryButtonTitle: "İptal"
        )
    }
}