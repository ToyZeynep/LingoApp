//
//  KeyboardView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

struct KeyboardView: View {
    @ObservedObject var game: GameModel
    
    private let keyboardRows = [
        ["E", "R", "T", "Y", "U", "I", "O", "P", "Ğ", "Ü"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ş", "İ"],
        ["Z", "X", "C", "V", "B", "N", "M", "Ö", "Ç"]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 16 // Padding için
            let buttonWidth = min(availableWidth / 11, 32) // Maksimum 32, minimum hesaplanacak
            let actualButtonWidth = max(buttonWidth, 28) // Minimum 28 genişlik
            
            VStack(spacing: 8) {
                // İlk satır
                HStack(spacing: 3) {
                    ForEach(keyboardRows[0], id: \.self) { key in
                        if !game.jokerManager.removedLetters.contains(Character(key)) {
                            Button(key) {
                                game.addLetter(key)
                            }
                            .keyboardButtonStyle(
                                width: actualButtonWidth,
                                backgroundColor: getKeyColor(for: key),
                                textColor: getKeyTextColor(for: key)
                            )
                            .disabled(game.gameState != .playing)
                        }
                    }
                }
                
                // İkinci satır
                HStack(spacing: 3) {
                    ForEach(keyboardRows[1], id: \.self) { key in
                        if !game.jokerManager.removedLetters.contains(Character(key)) {
                            Button(key) {
                                game.addLetter(key)
                            }
                            .keyboardButtonStyle(
                                width: actualButtonWidth,
                                backgroundColor: getKeyColor(for: key),
                                textColor: getKeyTextColor(for: key)
                            )
                            .disabled(game.gameState != .playing)
                        }
                    }
                }
                
                // Üçüncü satır (ENTER + harfler + DELETE)
                HStack(spacing: 3) {
                    Button("GİR") {
                        game.makeGuess()
                    }
                    .keyboardButtonStyle(
                        width: actualButtonWidth * 1.3,
                        backgroundColor: .cyan,
                        textColor: .white
                    )
                    .disabled(game.currentGuess.count != game.wordLength || game.gameState != .playing)
                    
                    ForEach(keyboardRows[2], id: \.self) { key in
                        Button(key) {
                            game.addLetter(key)
                        }
                        .keyboardButtonStyle(
                            width: actualButtonWidth,
                            backgroundColor: getKeyColor(for: key),
                            textColor: getKeyTextColor(for: key)
                        )
                        .disabled(game.gameState != .playing)
                    }
                    
                    Button("⌫") {
                        game.deleteLetter()
                    }
                    .keyboardButtonStyle(
                        width: actualButtonWidth * 1.3,
                        backgroundColor: .red.opacity(0.8),
                        textColor: .white
                    )
                    .disabled(game.currentGuess.isEmpty || game.gameState != .playing)
                }
            }
        }
        .frame(height: 120)
        .padding(.horizontal, 8)
    }
    
    private func getKeyColor(for key: String) -> Color {
        let keyChar = Character(key)
        
        // Tüm tahminleri kontrol et
        for guess in game.guesses {
            for letterState in guess.letters {
                if letterState.letter == keyChar {
                    switch letterState.state {
                    case .correct:
                        return .cyan
                    case .wrongPosition:
                        return .orange
                    case .wrong:
                        return .gray.opacity(0.6)
                    case .unused:
                        continue
                    }
                }
            }
        }
        
        return Color.cyan.opacity(0.15)
    }
    
    private func getKeyTextColor(for key: String) -> Color {
        let keyChar = Character(key)
        
        for guess in game.guesses {
            for letterState in guess.letters {
                if letterState.letter == keyChar {
                    switch letterState.state {
                    case .correct, .wrong, .wrongPosition:
                        return .white
                    case .unused:
                        continue
                    }
                }
            }
        }
        
        return .cyan.opacity(0.9)
    }
}

// MARK: - Klavye Buton Stili
struct KeyboardButtonStyle: ViewModifier {
    let width: CGFloat
    let backgroundColor: Color
    let textColor: Color
    
    init(width: CGFloat = 32, backgroundColor: Color = .gray.opacity(0.2), textColor: Color = .primary) {
        self.width = width
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(textColor)
            .frame(width: width, height: 42)
            .background(backgroundColor)
            .cornerRadius(6)
    }
}

extension View {
    func keyboardButtonStyle(width: CGFloat = 32, backgroundColor: Color = Color.cyan.opacity(0.15), textColor: Color = .cyan.opacity(0.9)) -> some View {
        self.modifier(KeyboardButtonStyle(width: width, backgroundColor: backgroundColor, textColor: textColor))
    }
}

// MARK: - Preview
struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView(game: GameModel())
    }
}
