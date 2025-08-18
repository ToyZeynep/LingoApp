//
//  AdStatusBanner.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct AdStatusBanner: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    let showSpinner: Bool
    let action: (() -> Void)?
    
    init(icon: String, title: String, message: String, color: Color, showSpinner: Bool, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.color = color
        self.showSpinner = showSpinner
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                if showSpinner {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: color))
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if let action = action {
                Button("Tekrar Dene") {
                    action()
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}


