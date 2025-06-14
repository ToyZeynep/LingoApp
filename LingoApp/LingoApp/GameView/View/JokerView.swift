//
//  JokerView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI
import AVFoundation

// MARK: - Kompakt Joker View (Letter Box altında)
struct JokerCompactView: View {
    @ObservedObject var game: GameModel
    @State private var showJokerShop = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Joker başlığı ve mağaza butonu
            HStack {
                Text("🃏 JOKERLER")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.cyan.opacity(0.9))
                
                Spacer()
                
                Button("+ JOKER AL") {
                    showJokerShop = true
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.yellow)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .stroke(.yellow.opacity(0.6), lineWidth: 1)
                        .background(Capsule().fill(.yellow.opacity(0.2)))
                )
            }
            
            // Tek sırada büyük joker butonları
            HStack(spacing: 10) {
                ForEach(JokerType.allCases, id: \.self) { jokerType in
                    BigJokerButton(
                        type: jokerType,
                        count: game.jokerManager.jokers.count(for: jokerType),
                        isDisabled: game.jokerManager.jokers.count(for: jokerType) == 0
                    ) {
                        useJoker(jokerType)
                    }
                }
            }
        }
        .sheet(isPresented: $showJokerShop) {
            JokerShopView(jokerManager: game.jokerManager)
        }
        .alert("💡 İpucu", isPresented: $game.jokerManager.showHintPopup) {
            Button("Tamam") { }
        } message: {
            Text(game.jokerManager.currentHint)
        }
    }
    
    private func useJoker(_ type: JokerType) {
        let success = game.jokerManager.useJoker(type, targetWord: game.targetWord, gameModel: game)
        
        if success {
            AudioServicesPlaySystemSound(1057)
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(1053)
        }
    }
}

// MARK: - Büyük Parlak Joker Butonu
struct BigJokerButton: View {
    let type: JokerType
    let count: Int
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Ana ikon - çok parlak
                    Image(systemName: type.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    
                    // Sayı badge'i - süper parlak
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(
                                Circle()
                                    .fill(LinearGradient(colors: [.red, .red.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                    .overlay(Circle().stroke(.white, lineWidth: 2))
                                    .shadow(color: .red.opacity(0.5), radius: 3, x: 0, y: 1)
                            )
                            .offset(x: 14, y: -14)
                    }
                }
                
                Text(type.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
            .frame(width: 75, height: 65)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isDisabled ?
                            LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.3)], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [type.brightColor, type.brightColor.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isDisabled ? .gray.opacity(0.4) : .white.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: isDisabled ? .clear : type.brightColor.opacity(0.6), radius: 8, x: 0, y: 4)
            )
        }
        .disabled(isDisabled)
        .scaleEffect(isDisabled ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
    }
}

// MARK: - Joker Mağazası
struct JokerShopView: View {
    @ObservedObject var jokerManager: JokerManager
    @Environment(\.dismiss) private var dismiss
    @State private var showAdReward = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Başlık
                VStack(spacing: 10) {
                    Text("🃏")
                        .font(.system(size: 60))
                    
                    Text("JOKER MAĞAZASI")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                
                // Mevcut Jokerler
                VStack(alignment: .leading, spacing: 15) {
                    Text("Mevcut Jokerleriniz:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(JokerType.allCases, id: \.self) { type in
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundColor(type.brightColor)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(jokerManager.jokers.count(for: type))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(type.brightColor)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(type.brightColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(type.brightColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                
                // Reklam ile Joker Kazan
                Button(action: {
                    showAdReward = true
                }) {
                    HStack {
                        Image(systemName: "tv.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text("REKLAM İZLE")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("Ücretsiz joker kazan!")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Text("🎁")
                            .font(.title)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Joker Mağazası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
        .alert("🎁 Tebrikler!", isPresented: $showAdReward) {
            Button("Harika!") {
                jokerManager.earnJokersFromAd()
                dismiss()
            }
        } message: {
            Text("Reklam izlediğiniz için rastgele bir joker kazandınız!")
        }
    }
}

// MARK: - Preview
struct JokerView_Previews: PreviewProvider {
    static var previews: some View {
        JokerCompactView(game: GameModel(difficulty: .medium))
            .padding()
    }
}
