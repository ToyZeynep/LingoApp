//
//  JokerShopView.swift
//  LingoApp
//
//  Updated with better ad error handling and user feedback
//

import SwiftUI

struct JokerShopView: View {
    @ObservedObject var jokerManager: JokerManager
    @StateObject private var adMobManager = AdMobManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var selectedJokerType: JokerType?
    @State private var isWatchingAd = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.3),
                    Color(red: 0.08, green: 0.12, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Arkaplan efektleri
            Circle()
                .fill(.cyan.opacity(0.08))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(.blue.opacity(0.12))
                .frame(width: 150, height: 150)
                .blur(radius: 50)
                .offset(x: 120, y: 300)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    headerSection
                    
                    // Reklam durumu bildirimi
                    adStatusSection
                    
                    // Mevcut jokerler
                    currentJokersSection
                    
                    // Ücretsiz joker alma bölümü
                    freeJokerSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Tamam") { }
            
            // Eğer reklam yüklenemiyorsa tekrar dene butonu
            if alertTitle.contains("Reklam") && !adMobManager.canShowRewardedAd {
                Button("Tekrar Dene") {
                    adMobManager.reloadAllAds()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            adMobManager.reloadAllAds()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Kapat")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.cyan.opacity(0.9))
            }
            
            Spacer()
            
            Text("🃏 JOKER MAĞAZASI")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Boş alan (simetri için)
            Color.clear
                .frame(width: 60)
        }
    }
    
    private var adStatusSection: some View {
          Group {
              if adMobManager.isLoading {
                  AdStatusBanner(
                      icon: "arrow.2.circlepath",
                      title: "Reklamlar Yükleniyor",
                      message: "Lütfen bekleyiniz...",
                      color: .orange,
                      showSpinner: true
                  )
              } else if !adMobManager.canShowRewardedAd {
                  AdStatusBanner(
                      icon: "exclamationmark.triangle.fill",
                      title: "Reklam Mevcut Değil",
                      message: "Şu anda gösterilecek reklam bulunmuyor. İnternet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.",
                      color: .red,
                      showSpinner: false
                  ) {
                      adMobManager.reloadAllAds()
                  }
              } else {
                  AdStatusBanner(
                      icon: "checkmark.circle.fill",
                      title: "Reklamlar Hazır!",
                      message: "Ücretsiz joker kazanmak için reklam izleyebilirsiniz",
                      color: .green,
                      showSpinner: false
                  )
              }
          }
      }
    
    // MARK: - Mevcut Jokerler
    private var currentJokersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Mevcut Jokerleriniz")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
                ForEach(JokerType.allCases, id: \.self) { jokerType in
                    JokerInventoryCard(
                        type: jokerType,
                        count: jokerManager.jokers.count(for: jokerType)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - Ücretsiz Joker Alma
    private var freeJokerSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "tv.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                
                Text("Ücretsiz Joker Kazan")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text("Reklam izleyerek ücretsiz joker kazanabilirsin! (Her reklam +3 joker)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
                ForEach(JokerType.allCases, id: \.self) { jokerType in
                    FreeJokerButton(
                        type: jokerType,
                        isAdReady: adMobManager.canShowRewardedAd,
                        isLoading: adMobManager.isLoading,
                        isWatchingAd: isWatchingAd && selectedJokerType == jokerType
                    ) {
                        watchAdForJoker(jokerType)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.yellow.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .yellow.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - Actions
    private func watchAdForJoker(_ jokerType: JokerType) {
        selectedJokerType = jokerType
        isWatchingAd = true
        
        // Önce reklam durumunu kontrol et
        if !adMobManager.canShowRewardedAd {
            isWatchingAd = false
            selectedJokerType = nil
            
            if adMobManager.isLoading {
                showAlert(
                    title: "Reklamlar Yükleniyor",
                    message: "Lütfen reklamların yüklenmesini bekleyin ve tekrar deneyin."
                )
            } else {
                showAlert(
                    title: "Reklam Bulunamadı",
                    message: "Şu anda gösterilecek reklam bulunmuyor. İnternet bağlantınızı kontrol edin ve birkaç dakika sonra tekrar deneyin."
                )
            }
            return
        }
        
        adMobManager.showRewardedAdWithFallback { [self] success in
            DispatchQueue.main.async {
                isWatchingAd = false
                
                if success, let jokerType = selectedJokerType {
                    let rewardAmount = 3
                    jokerManager.addJoker(jokerType, count: rewardAmount)
                    
                    showAlert(
                        title: "🎉 Tebrikler!",
                        message: "\(jokerType.title) jokerinden \(rewardAmount) adet kazandınız!"
                    )
                } else {
                    // Kullanıcı reklamı yarıda bıraktı veya başka bir sorun oldu
                    showAlert(
                        title: "Reklam Tamamlanamadı",
                        message: "Ücretsiz joker kazanmak için reklamı sonuna kadar izlemeniz gerekmektedir."
                    )
                }
                selectedJokerType = nil
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Supporting Views

struct AdStatusBanner: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    let showSpinner: Bool
    let action: (() -> Void)?
    
    init(icon: String, title: String, message: String, color: Color, showSpinner: Bool, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.color = color
        self.showSpinner = showSpinner
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                if showSpinner {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: color))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if let action = action {
                Button("Tekrar Dene") {
                    action()
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct JokerInventoryCard: View {
    let type: JokerType
    let count: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: type.icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(type.brightColor)
            
            Text(type.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.cyan)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.brightColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct FreeJokerButton: View {
    let type: JokerType
    let isAdReady: Bool
    let isLoading: Bool
    let isWatchingAd: Bool
    let action: () -> Void
    
    private var buttonState: ButtonState {
        if isWatchingAd {
            return .watching
        } else if isLoading {
            return .loading
        } else if isAdReady {
            return .ready
        } else {
            return .unavailable
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                
                Image(systemName: type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(buttonState.iconColor(for: type))
                
                Text(type.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if buttonState == .watching {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                } else {
                    Text(buttonState.buttonText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(buttonState.textColor)
                }
            }
            .frame(height: 85)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(buttonState.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(buttonState.borderColor, lineWidth: 1)
                    )
            )
        }
        .disabled(!buttonState.isEnabled)
        .scaleEffect(buttonState.isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: buttonState)
    }
    
    private enum ButtonState: Equatable {
        case ready
        case loading
        case watching
        case unavailable
        
        var buttonText: String {
            switch self {
            case .ready: return "Reklam İzle"
            case .loading: return "Yükleniyor..."
            case .watching: return "Reklam Gösteriliyor..."
            case .unavailable: return "Reklam Yok"
            }
        }
        
        func iconColor(for type: JokerType) -> Color {
            switch self {
            case .ready: return type.brightColor
            case .loading: return .gray
            case .watching: return type.brightColor.opacity(0.8)
            case .unavailable: return .gray
            }
        }
        
        var textColor: Color {
            switch self {
            case .ready: return .yellow
            case .loading: return .gray
            case .watching: return .yellow
            case .unavailable: return .red.opacity(0.7)
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .ready: return .yellow.opacity(0.15)
            case .loading: return .gray.opacity(0.1)
            case .watching: return .yellow.opacity(0.2)
            case .unavailable: return .red.opacity(0.1)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .ready: return .yellow.opacity(0.4)
            case .loading: return .gray.opacity(0.3)
            case .watching: return .yellow.opacity(0.5)
            case .unavailable: return .red.opacity(0.3)
            }
        }
        
        var isEnabled: Bool {
            switch self {
            case .ready: return true
            case .loading, .watching, .unavailable: return false
            }
        }
    }
}
