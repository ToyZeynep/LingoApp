//
//  LetterBox.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

struct LetterBox: View {
    let letter: Character?
    let state: LetterGuessState
    let boxSize: CGFloat
    let isLastRow: Bool  // ✅ YENİ: Son satır mı kontrol et
    
    @State private var isAnimating = false
    @State private var flipRotation: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(backgroundColor)
            .frame(width: boxSize, height: boxSize)
            .overlay(
                Text(letter.map(String.init) ?? "")
                    .font(.system(size: boxSize * 0.4, weight: .medium))
                    .foregroundColor(textColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .opacity(state == .unused && letter == nil ? 1 : 0)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .rotation3DEffect(
                .degrees(flipRotation),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(.easeInOut(duration: 0.15), value: isAnimating)
            .animation(.easeInOut(duration: 0.6), value: flipRotation)
            .onChange(of: letter) { _ in
                // Harf yazılırken küçük animasyon
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation {
                        isAnimating = false
                    }
                }
            }
            .onChange(of: state) { newState in
                if newState != .unused && isLastRow {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        flipRotation = 90
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flipRotation = 0
                        }
                    }
                }
            }
    }
    
    private var backgroundColor: LinearGradient {
        switch state {
        case .correct, .revealed:
            return LinearGradient(
                colors: [Color.cyan, Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .wrongPosition:
            return LinearGradient(
                colors: [Color.orange, Color.yellow.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .wrong:
            return LinearGradient(
                colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .unused:
            return letter != nil ?
                LinearGradient(
                    colors: [Color.cyan.opacity(0.15), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [Color.clear, Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
        }
    }
    
    private var textColor: Color {
        switch state {
        case .correct, .wrong, .revealed:
            return .white
        case .wrongPosition:
            return .white
        case .unused:
            return letter != nil ? .cyan.opacity(0.9) : .cyan.opacity(0.4)
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .unused:
            return letter != nil ? .cyan.opacity(0.4) : .cyan.opacity(0.2)
        default:
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch state {
        case .unused:
            return letter != nil ? 1.5 : 1
        default:
            return 0
        }
    }
    
    private var shadowColor: Color {
        switch state {
        case .correct:
            return .cyan.opacity(0.4)
        case .wrongPosition:
            return .orange.opacity(0.4)
        case .wrong:
            return .gray.opacity(0.3)
        case .unused:
            return .black.opacity(0.15)
        case .revealed:
            return .cyan.opacity(0.4)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch state {
        case .unused:
            return 3
        default:
            return 6
        }
    }
    
    private var shadowOffset: CGFloat {
        switch state {
        case .unused:
            return 2
        default:
            return 4
        }
    }
}
