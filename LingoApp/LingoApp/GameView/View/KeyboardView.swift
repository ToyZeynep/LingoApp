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
        ["SİL", "Z", "C", "V", "B", "N", "M", "Ö", "Ç", "ENTER"]
    ]
    
    private var remainingLettersNeeded: Int {
        return game.wordLength - game.revealedPositions.count
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { rowIndex in
                HStack(spacing: 3) {
                    ForEach(keyboardRows[rowIndex], id: \.self) { key in
                        if key == "SİL" {
                            Button(action: {
                                game.deleteLetter()
                            }) {
                                Image(systemName: "delete.left.fill")
                                    .font(.system(size: 18, weight: .medium))
                            }
                            .keyboardButtonStyle(
                                width: (UIScreen.main.bounds.width - 30) / 9.5,
                                height: 50,
                                fontSize: 16,
                                backgroundColor: .red.opacity(0.85),
                                textColor: .white
                            )
                            .disabled(game.currentGuess.isEmpty || game.gameState != .playing)
                        } else if key == "ENTER" {
                            Button(action: {
                                game.makeGuess()
                            }) {
                                Image(systemName: "return")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .keyboardButtonStyle(
                                width: (UIScreen.main.bounds.width - 30) / 9.5,
                                height: 50,
                                fontSize: 16,
                                backgroundColor: .cyan,
                                textColor: .white
                            )
                            .disabled(game.currentGuess.count != remainingLettersNeeded || game.gameState != .playing)
                        } else {
                            // Normal harf tuşları - silinen harfler gri gösterilecek
                            let isRemoved = game.jokerManager.removedLetters.contains(Character(key))
                            
                            Button(action: {
                                if !isRemoved {
                                    game.addLetter(key)
                                }
                            }) {
                                Text(key)
                            }
                            .keyboardButtonStyle(
                                width: rowIndex == 0 ?
                                    (UIScreen.main.bounds.width - 35) / 10.2 :
                                    rowIndex == 1 ?
                                    (UIScreen.main.bounds.width - 38) / 11.2 :
                                    (UIScreen.main.bounds.width - 32) / 11.5,
                                height: 50,
                                fontSize: 18,
                                backgroundColor: isRemoved ?
                                    .gray.opacity(0.3) :  // Silinen harfler soluk gri
                                    getKeyColor(for: key),
                                textColor: isRemoved ?
                                    .gray.opacity(0.5) :  // Silinen harf metni de soluk
                                    getKeyTextColor(for: key)
                            )
                            .disabled(game.gameState != .playing || isRemoved)
                            .overlay(
                                // Silinen harfler için çarpı işareti (opsiyonel)
                                isRemoved ?
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.red.opacity(0.3))
                                    .offset(x: 12, y: -12)
                                : nil
                            )
                        }
                    }
                }
            }
        }
        .frame(height: 170)
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

struct KeyboardButtonStyle: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    let fontSize: CGFloat
    let backgroundColor: Color
    let textColor: Color
    
    init(width: CGFloat, height: CGFloat = 40, fontSize: CGFloat = 14, backgroundColor: Color, textColor: Color) {
        self.width = width
        self.height = height
        self.fontSize = fontSize
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundColor(textColor)
            .frame(width: width, height: height)
            .background(backgroundColor)
            .cornerRadius(8)
    }
}

extension View {
    func keyboardButtonStyle(
        width: CGFloat = 32,
        height: CGFloat = 40,
        fontSize: CGFloat = 14,
        backgroundColor: Color = Color.cyan.opacity(0.15),
        textColor: Color = .cyan.opacity(0.9)
    ) -> some View {
        self.modifier(KeyboardButtonStyle(
            width: width,
            height: height,
            fontSize: fontSize,
            backgroundColor: backgroundColor,
            textColor: textColor
        ))
    }
}
