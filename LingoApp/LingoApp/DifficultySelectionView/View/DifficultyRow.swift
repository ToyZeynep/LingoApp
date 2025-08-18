//
//  DifficultyRow.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct DifficultyRow: View {
    let level: DifficultyLevel
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(level.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(level.color.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(level.color.opacity(0.5), lineWidth: 1)
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(level.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(level.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
