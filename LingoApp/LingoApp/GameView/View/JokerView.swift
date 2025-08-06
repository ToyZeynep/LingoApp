//
//  JokerView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI
import AVFoundation

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
    }
    
    // ✅ DÜZELTME: Yeni useJoker fonksiyonu
    private func useJoker(_ type: JokerType) {
        // Joker sayısını kontrol et
        guard game.jokerManager.jokers.count(for: type) > 0 else {
            // Ses ayarını kontrol et
            if game.soundEnabled {
                AudioServicesPlaySystemSound(1053)
            }
            return
        }
        
        // Joker sayısını azalt
        let success = game.jokerManager.jokers.use(type)
        
        if success {
            // Joker türüne göre aksiyonu gerçekleştir
            switch type {
            case .revealLetter:
                game.useJoker() // ✅ GameModel'deki useJoker fonksiyonunu çağır
                
            case .removeLetter:
                // Yanlış harfleri kaldır (eski mantık)
                let alphabet = "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ"
                let targetLetters = Set(game.targetWord)
                
                for char in alphabet {
                    if !targetLetters.contains(char) {
                        game.jokerManager.removedLetters.insert(char)
                    }
                }
                
            case .extraTime:
                game.addExtraTime(30) // 30 saniye ekle
            }
            
            // Kullanılan jokeri işaretle
            game.jokerManager.usedJokersInCurrentGame.insert(type)
            game.jokerManager.saveJokers()
            
            // Başarı sesi
            if game.soundEnabled {
                AudioServicesPlaySystemSound(1057)
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        } else {
            // Hata sesi
            if game.soundEnabled {
                AudioServicesPlaySystemSound(1053)
            }
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

// MARK: - Preview
struct JokerView_Previews: PreviewProvider {
    static var previews: some View {
        JokerCompactView(game: GameModel(difficulty: .medium))
            .padding()
    }
}
