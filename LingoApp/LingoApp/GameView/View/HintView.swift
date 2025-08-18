//
//  HintView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 16.08.2025.
//


import SwiftUI

struct HintView: View {
    let meaning: String
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("İPUCU".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
                
                Spacer()
            }
            
            HStack {
                Text(meaning)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.yellow.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .yellow.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                isVisible = true
            }
        }
    }
}
