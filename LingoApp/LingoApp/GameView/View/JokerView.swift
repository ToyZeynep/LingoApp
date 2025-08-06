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
    @State private var selectedJokerType: JokerType?
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(JokerType.allCases, id: \.self) { jokerType in
                BigJokerButton(
                    type: jokerType,
                    count: game.jokerManager.jokers.count(for: jokerType),
                    onTap: {
                        handleJokerTap(jokerType)
                    },
                    onLongPress: {
                        selectedJokerType = jokerType
                        showJokerShop = true
                    }
                )
            }
        }
        .sheet(isPresented: $showJokerShop) {
            JokerShopView(
                jokerManager: game.jokerManager
            )
        }
    }
    
    private func handleJokerTap(_ type: JokerType) {
        if game.jokerManager.jokers.count(for: type) == 0 {
            selectedJokerType = type
            showJokerShop = true
            
            if game.soundEnabled {
                AudioServicesPlaySystemSound(1053)
            }
            return
        }
        
        useJoker(type)
    }
    
    private func useJoker(_ type: JokerType) {
        guard game.jokerManager.jokers.count(for: type) > 0 else {
            if game.soundEnabled {
                AudioServicesPlaySystemSound(1053)
            }
            return
        }
        
        let success = game.jokerManager.jokers.use(type)
        
        if success {
            switch type {
            case .revealLetter:
                game.useJoker()
                
            case .removeLetter:
                let alphabet = "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ"
                let targetLetters = Set(game.targetWord)
                
                for char in alphabet {
                    if !targetLetters.contains(char) {
                        game.jokerManager.removedLetters.insert(char)
                    }
                }
                
            case .extraTime:
                game.addExtraTime(30)
            }
            
            game.jokerManager.usedJokersInCurrentGame.insert(type)
            game.jokerManager.saveJokers()
            
            if game.soundEnabled {
                AudioServicesPlaySystemSound(1057)
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        } else {
            if game.soundEnabled {
                AudioServicesPlaySystemSound(1053)
            }
        }
    }
}

struct BigJokerButton: View {
    let type: JokerType
    let count: Int
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Image(systemName: type.icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    
                    ZStack {
                        if count > 0 {
                            Text("\(count)")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(
                                    Circle()
                                        .fill(type.brightColor)
                                        .overlay(Circle().stroke(.white, lineWidth: 2))
                                        .shadow(color: type.brightColor.opacity(0.5), radius: 3, x: 0, y: 1)
                                )
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(type.brightColor)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 18, height: 18)
                                )
                                .shadow(color: type.brightColor.opacity(0.6), radius: 3, x: 0, y: 1)
                        }
                    }
                    .offset(x: 15, y: -15)
                }
                
                Text(type.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
            .frame(width: 75, height: 68)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [
                                type.brightColor.opacity(count > 0 ? 0.9 : 0.3),
                                type.brightColor.opacity(count > 0 ? 0.7 : 0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(count > 0 ? 0.3 : 0.15), lineWidth: 2)
                    )
                    .shadow(color: type.brightColor.opacity(count > 0 ? 0.5 : 0.2), radius: 8, x: 0, y: 4)
            )
            .overlay(
                count == 0 ?
                RoundedRectangle(cornerRadius: 14)
                    .stroke(type.brightColor.opacity(0.3), lineWidth: 2)
                    .scaleEffect(isPressed ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: count)
                : nil
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }) {
            onLongPress()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
    }
}
