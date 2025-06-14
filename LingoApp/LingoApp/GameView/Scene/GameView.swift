//
//  GameView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

struct GameView: View {
    let difficulty: DifficultyLevel
    let onBackToMenu: () -> Void
    
    @StateObject private var game: GameModel
    @State private var showStatistics = false
    @State private var showGameOver = false
    
    init(difficulty: DifficultyLevel, onBackToMenu: @escaping () -> Void) {
        self.difficulty = difficulty
        self.onBackToMenu = onBackToMenu
        self._game = StateObject(wrappedValue: GameModel(difficulty: difficulty))
    }
    
    var body: some View {
        ZStack {
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
                
                Circle()
                    .fill(.cyan.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -100, y: -200)
                
                Circle()
                    .fill(.blue.opacity(0.12))
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)
                    .offset(x: 120, y: 150)
                
                RoundedRectangle(cornerRadius: 50)
                    .fill(.indigo.opacity(0.1))
                    .frame(width: 180, height: 100)
                    .blur(radius: 40)
                    .offset(x: -50, y: 100)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 15) {
                        if game.gameState == .playing {
                            HStack {
                                Button(action: onBackToMenu) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "chevron.left.circle.fill")
                                            .font(.system(size: 16))
                                        Text("Geri")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(.cyan.opacity(0.9))
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        
                        TimerProgressView(game: game)
                            .padding(.horizontal)
                        
                        GameBoard(game: game)
                            .padding(.horizontal)
                        
                        KeyboardView(game: game)
                            .padding(.bottom, 10)
                    }
                }
            }
        }
        .alert("Geçersiz Kelime", isPresented: $game.showInvalidWordAlert) {
            Button("Tamam") { }
        } message: {
            Text("Lütfen geçerli bir Türkçe kelime girin.")
        }
        .onChange(of: game.gameState) { newState in
            if newState != .playing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showGameOver = true
                }
            }
        }
        .alert(game.gameState == .won ? "Tebrikler! 🎉" : "Oyun Bitti 😔",
               isPresented: $showGameOver) {
            Button("Yeni Oyun") {
                game.startNewGame()
            }
        } message: {
            if game.gameState == .won {
                Text("Doğru kelime: \(game.targetWord)\n\(game.guesses.count) tahminde buldunuz!")
            } else {
                Text("Doğru kelime: \(game.targetWord)")
            }
        }
    }
}

// MARK: - Timer Progress View
struct TimerProgressView: View {
    @ObservedObject var game: GameModel
    
    var progressValue: Double {
        game.timeRemaining / game.gameDuration
    }
    
    var timeColor: Color {
        if game.timeRemaining > 60 {
            return .red
        } else if game.timeRemaining > 30 {
            return .orange
        } else {
            return .red.opacity(0.8)
        }
    }
    
    var formattedTime: String {
        let minutes = Int(game.timeRemaining) / 60
        let seconds = Int(game.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Süre metni
            HStack {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundColor(timeColor)
                
                Text(formattedTime)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(timeColor)
                
                Spacer()
                
                if game.timeRemaining <= 10 && game.timeRemaining > 0 {
                    Text("⚠️")
                        .font(.caption)
                        .foregroundColor(.red)
                        .animation(.blink(duration: 0.5), value: game.timeRemaining)
                }
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                // Arkaplan
                RoundedRectangle(cornerRadius: 6)
                    .fill(.ultraThinMaterial)
                    .frame(height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                
                // Progress
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: progressValue > 0.5 ?
                            [.red, .red.opacity(0.8)] :
                                progressValue > 0.25 ?
                            [.orange, .red] :
                                [.red, .red.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, UIScreen.main.bounds.width * 0.8 * progressValue), height: 8)
                    .animation(.linear(duration: 1), value: progressValue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(timeColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Oyun Tahtası
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
            // Harf Kutuları
            VStack(spacing: 12) {
                ForEach(0..<game.maxGuesses, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<game.wordLength, id: \.self) { col in
                            LetterBox(
                                letter: game.getLetterForPosition(row: row, col: col),
                                state: game.getStateForPosition(row: row, col: col),
                                boxSize: boxSize
                            )
                        }
                    }
                }
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

// MARK: - Animation Extension
extension Animation {
    static func blink(duration: Double = 1.0) -> Animation {
        Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}

// MARK: - Preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(difficulty: .medium, onBackToMenu: {
            print("Back to menu")
        })
    }
}
