//
//  TimerProgressView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 17.08.2025.
//

import SwiftUI

struct TimerProgressView: View {
    @ObservedObject var game: GameModel
    
    var progressValue: Double {
        min(game.timeRemaining / game.gameDuration, 1.0) // 1.0'ı geçmemesini sağla
    }
    
    var timeColor: Color {
        if game.timeRemaining > 60 {
            return .green
        } else if game.timeRemaining > 30 {
            return .orange
        } else {
            return .red.opacity(0.8)
        }
    }
    
    var formattedTime: String {
        let minutes = Int(game.timeRemaining) / 60
        let seconds = Int(game.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Süre metni
            HStack {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundColor(timeColor)
                
                Text(formattedTime)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(timeColor)
                
                Spacer()
                
                if game.timeRemaining <= 10 && game.timeRemaining > 0 {
                    Text("⚠️")
                        .font(.caption)
                        .foregroundColor(.red)
                        .animation(.blink(duration: 0.5), value: game.timeRemaining)
                }
            }
            
            // Progress bar - SABİT GENİŞLİK
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Arkaplan - tam genişlik
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.ultraThinMaterial)
                        .frame(height: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Progress - dinamik genişlik ama sınırlı
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: progressValue > 0.5 ?
                                [.green, .green.opacity(0.8)] :
                                    progressValue > 0.25 ?
                                [.orange, .red] :
                                    [.red, .red.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * progressValue), height: 8)
                        .animation(.linear(duration: 1), value: progressValue)
                }
            }
            .frame(height: 8) // Progress bar yüksekliği sabit
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(timeColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
