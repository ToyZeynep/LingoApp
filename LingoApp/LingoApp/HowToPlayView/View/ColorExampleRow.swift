//
//  ColorExampleRow.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct ColorExampleRow: View {
    let letter: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(letter)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
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
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
