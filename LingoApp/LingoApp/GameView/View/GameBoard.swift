//
//  GameBoard.swift
//  LingoApp
//
//  Created by Zeynep Toy on 17.08.2025.
//

import SwiftUI


// GameView.swift - GameBoard struct'ını şöyle güncelleyin:

struct GameBoard: View {
    @ObservedObject var game: GameModel
    
    // Dinamik kutu boyutu hesapla
    private var boxSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - 80 // Padding için
        let spacing = CGFloat(game.wordLength - 1) * 8 // Kutular arası boşluk
        return min((availableWidth - spacing) / CGFloat(game.wordLength), 55)
    }
    
    private var spacing: CGFloat {
        game.wordLength > 5 ? 6 : 8
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // ✅ Basit ScrollView - Orijinal mantıkla
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<max(game.guesses.count + 1, game.visibleGuesses), id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(0..<game.wordLength, id: \.self) { col in
                                    LetterBox(
                                        letter: game.getLetterForPosition(row: row, col: col),
                                        state: game.getStateForPosition(row: row, col: col),
                                        boxSize: boxSize,
                                        isLastRow: row == game.guesses.count - 1
                                    )
                                }
                            }
                            .id("row_\(row)")
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: CGFloat(game.visibleGuesses) * (boxSize + 12))
                .clipped()
                .onChange(of: game.guesses.count) { count in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("row_\(count)", anchor: .bottom)
                    }
                }
            }
            
            // Tahmin sayacı
            if game.guesses.count > 0 {
                HStack {
                    Image(systemName: "number.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.cyan)
                    
                    Text("Tahmin: \(game.guesses.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
            
            JokerCompactView(game: game)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
    }
}
