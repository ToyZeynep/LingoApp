//
//  JokerShopView.swift
//  LingoApp
//
//  Updated with dark theme matching main app design
//

import SwiftUI

struct JokerShopView: View {
    @ObservedObject var jokerManager: JokerManager
    @StateObject private var adMobManager = AdMobManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showRewardAlert = false
    @State private var rewardMessage = ""
    @State private var selectedJokerType: JokerType?
    
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
                    
                    // Mevcut jokerler
                    currentJokersSection
                    
                    // Ücretsiz joker alma bölümü
                    freeJokerSection
                    
                    // Premium satın alma bölümü
                    premiumSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .alert("🎉 Tebrikler!", isPresented: $showRewardAlert) {
            Button("Harika!") { }
        } message: {
            Text(rewardMessage)
        }
        .onAppear {
            adMobManager.reloadAllAds()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button("Kapat") {
                dismiss()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.cyan.opacity(0.9))
            
            Spacer()
            
            Text("🃏 JOKER MAĞAZASI")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Boş alan (simetri için)
            Color.clear
                .frame(width: 50)
        }
    }
    
    // MARK: - Mevcut Jokerler
    private var currentJokersSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Mevcut Jokerleriniz")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
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
                
                if adMobManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                }
            }
            
            Text("Reklam izleyerek ücretsiz joker kazanabilirsin!")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(JokerType.allCases, id: \.self) { jokerType in
                    FreeJokerButton(
                        type: jokerType,
                        isAdReady: adMobManager.canShowRewardedAd,
                        isLoading: adMobManager.isLoading
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
    
    // MARK: - Premium Bölümü
    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.purple)
                
                Text("Premium Joker Paketleri")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                PremiumPackageButton(
                    title: "Başlangıç Paketi",
                    description: "Her jokerden 3'er adet",
                    price: "₺9.99",
                    jokerCounts: [3, 3, 3]
                ) {
                    purchasePremiumPackage(.starter)
                }
                
                PremiumPackageButton(
                    title: "Mega Paket",
                    description: "Her jokerden 10'ar adet",
                    price: "₺24.99",
                    jokerCounts: [10, 10, 10]
                ) {
                    purchasePremiumPackage(.mega)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.purple.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .purple.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - Actions
    private func watchAdForJoker(_ jokerType: JokerType) {
        selectedJokerType = jokerType
        
        // Fallback mekanizması ile reklam göster
        adMobManager.showRewardedAdWithFallback { [self] success in
            DispatchQueue.main.async {
                if success, let jokerType = selectedJokerType {
                    let rewardAmount = 10
                    jokerManager.addJoker(jokerType, count: rewardAmount)
                    
                    rewardMessage = "\(jokerType.title) jokerinden \(rewardAmount) adet kazandınız!"
                    showRewardAlert = true
                } else {
                    // Network sorunu varsa alternatif mesaj
                    if !adMobManager.isNetworkAvailable {
                        rewardMessage = "İnternet bağlantınızı kontrol edin ve tekrar deneyin."
                    } else {
                        rewardMessage = "Reklam şu anda mevcut değil. Lütfen daha sonra tekrar deneyin."
                    }
                    showRewardAlert = true
                }
                selectedJokerType = nil
            }
        }
    }
    
    private func purchasePremiumPackage(_ package: PremiumPackage) {
        switch package {
        case .starter:
            JokerType.allCases.forEach { type in
                jokerManager.addJoker(type, count: 3)
            }
            rewardMessage = "Başlangıç paketi satın alındı!"
        case .mega:
            JokerType.allCases.forEach { type in
                jokerManager.addJoker(type, count: 10)
            }
            rewardMessage = "Mega paket satın alındı!"
        }
        showRewardAlert = true
    }
}

// MARK: - Supporting Views

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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isAdReady ? type.brightColor : .gray)
                    
                    // TV ikonu overlay
                    Image(systemName: "tv.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                        .offset(x: 12, y: -12)
                }
                
                Text(type.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                } else {
                    Text(isAdReady ? "Reklam İzle" : "Yükleniyor...")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isAdReady ? .yellow : .gray)
                }
            }
            .frame(height: 85)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isAdReady ? .yellow.opacity(0.15) : .gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isAdReady ? .yellow.opacity(0.4) : .gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .disabled(!isAdReady && !isLoading) // Yükleniyor durumunda da aktif bırak
        .scaleEffect((isAdReady || isLoading) ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isAdReady)
    }
}

struct PremiumPackageButton: View {
    let title: String
    let description: String
    let price: String
    let jokerCounts: [Int]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.purple)
                    
                    Text("Satın Al")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.purple.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.purple.opacity(0.4), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Types
enum PremiumPackage {
    case starter
    case mega
}

// MARK: - Preview
struct JokerShopView_Previews: PreviewProvider {
    static var previews: some View {
        JokerShopView(jokerManager: JokerManager())
    }
}
