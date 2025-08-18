//
//  JokerInventoryCard.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct JokerInventoryCard: View {
    let type: JokerType
    let count: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: type.icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(type.brightColor)
            
            Text(type.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text("\(count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.cyan)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.brightColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
