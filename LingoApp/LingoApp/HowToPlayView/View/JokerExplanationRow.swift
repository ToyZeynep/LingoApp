//
//  JokerExplanationRow.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct JokerExplanationRow: View {
    let jokerType: JokerType
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: jokerType.icon)
                .font(.title2)
                .foregroundColor(jokerType.brightColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(jokerType.brightColor.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(jokerType.brightColor.opacity(0.5), lineWidth: 1)
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(jokerType.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(jokerType.description)
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
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
