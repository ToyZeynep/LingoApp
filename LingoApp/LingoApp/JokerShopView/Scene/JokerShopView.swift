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
                    headerSection
                    adStatusSection
                    currentJokersSection
                    freeJokerSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Tamam".localized) { }
            
            if alertTitle.contains("Reklam".localized) && !adMobManager.canShowRewardedAd {
                Button("Tekrar Dene".localized) {
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
                    Text("Kapat".localized)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.cyan.opacity(0.9))
            }
            
            Spacer()
            
            Text("JOKER MAĞAZASI".localized)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 60)
        }
    }
    
    private var adStatusSection: some View {
          Group {
              if adMobManager.isLoading {
                  AdStatusBanner(
                      icon: "arrow.2.circlepath",
                      title: "Reklamlar Yükleniyor".localized,
                      message: "Lütfen bekleyiniz...".localized,
                      color: .orange,
                      showSpinner: true
                  )
              } else if !adMobManager.canShowRewardedAd {
                  AdStatusBanner(
                      icon: "exclamationmark.triangle.fill",
                      title: "Reklam Mevcut Değil".localized,
                      message: "Şu anda gösterilecek reklam bulunmuyor.Daha sonra tekrar deneyin.".localized,
                      color: .red,
                      showSpinner: false
                  ) {
                      adMobManager.reloadAllAds()
                  }
              } else {
                  AdStatusBanner(
                      icon: "checkmark.circle.fill",
                      title: "Reklamlar Hazır!".localized,
                      message: "Ücretsiz joker kazanmak için reklam izleyebilirsiniz".localized,
                      color: .green,
                      showSpinner: false
                  )
              }
          }
      }
    
    // MARK: - Mevcut Jokerler
    private var currentJokersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Mevcut Jokerleriniz".localized)
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
                
                Text("Ücretsiz Joker Kazan".localized)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text("Reklam izleyerek ücretsiz joker kazanabilirsin! (Her reklam +3 joker)".localized)
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
        
        if !adMobManager.canShowRewardedAd {
            isWatchingAd = false
            selectedJokerType = nil
            
            if adMobManager.isLoading {
                showAlert(
                    title: "Reklamlar Yükleniyor".localized,
                    message: "Lütfen reklamların yüklenmesini bekleyin ve tekrar deneyin.".localized
                )
            } else {
                showAlert(
                    title: "Reklam Bulunamadı".localized,
                    message: "Şu anda gösterilecek reklam bulunmuyor. İnternet bağlantınızı kontrol edin ve birkaç dakika sonra tekrar deneyin.".localized
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
                        title: "🎉 Tebrikler!".localized,
                        message: String(format: NSLocalizedString("joker_earned_alert_message".localized, comment: ""),
                                        rewardAmount, jokerType.title)

                    )
                } else {
                    showAlert(
                        title: "Reklam Tamamlanamadı".localized,
                        message: "Ücretsiz joker kazanmak için reklamı sonuna kadar izlemeniz gerekmektedir.".localized
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
