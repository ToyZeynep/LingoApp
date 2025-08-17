//
//  InvalidWordToast.swift
//  LingoApp
//
//  Created by Zeynep Toy on 17.08.2025.
//


import SwiftUI

struct InvalidWordToast: View {
    @ObservedObject var game: GameModel
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundColor(.orange)
            
            Text("Lütfen geçerli Türkçe bir kelime girin")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.orange.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: -2)
        )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
         
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isVisible = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    game.showInvalidWordAlert = false
                }
            }
        }
    }
}
