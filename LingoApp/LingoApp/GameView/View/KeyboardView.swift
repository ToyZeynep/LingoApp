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
    
    private var remainingLettersNeeded: Int {
        return game.wordLength - game.revealedPositions.count
    }
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 16
            let buttonWidth = min(availableWidth / 12, 32)
            let actualButtonWidth = max(buttonWidth, 26)
            
            VStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { rowIndex in
                    HStack(spacing: 3) {
                        ForEach(keyboardRows[rowIndex], id: \.self) { key in
                            if !game.jokerManager.removedLetters.contains(Character(key)) {
                                Button(action: {
                                    game.addLetter(key)
                                }) {
                                    Text(key)
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
                }
                
                HStack(spacing: 3) {
                    ForEach(keyboardRows[2], id: \.self) { key in
                        if !game.jokerManager.removedLetters.contains(Character(key)) {
                            Button(action: {
                                game.addLetter(key)
                            }) {
                                Text(key)
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
                
                HStack(spacing: 10) {
                    Button("⌫") {
                        game.deleteLetter()
                    }
                    .keyboardButtonStyle(
                        width: actualButtonWidth * 2,
                        backgroundColor: .red.opacity(0.85),
                        textColor: .white
                    )
                    .disabled(game.currentGuess.isEmpty || game.gameState != .playing)
                    
                    Spacer()
                    
                    Button("GİR") {
                        game.makeGuess()
                    }
                    .keyboardButtonStyle(
                        width: actualButtonWidth * 2,
                        backgroundColor: .cyan,
                        textColor: .white
                    )
                    .disabled(game.currentGuess.count != remainingLettersNeeded || game.gameState != .playing)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 140)
    }
    
    private func getKeyColor(for key: String) -> Color {
        let keyChar = Character(key)
        for guess in game.guesses {
            for letterState in guess.letters {
                if letterState.letter == keyChar {
                    switch letterState.state {
                    case .correct, .revealed:
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
                    case .correct, .wrong, .wrongPosition, .revealed:
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
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(textColor)
            .frame(width: width, height: 40)
            .background(backgroundColor)
            .cornerRadius(6)
    }
}

extension View {
    func keyboardButtonStyle(width: CGFloat = 32, backgroundColor: Color = Color.cyan.opacity(0.15), textColor: Color = .cyan.opacity(0.9)) -> some View {
        self.modifier(KeyboardButtonStyle(width: width, backgroundColor: backgroundColor, textColor: textColor))
    }
}
