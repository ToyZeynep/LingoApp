//
//  FreeJokerButton.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct FreeJokerButton: View {
    let type: JokerType
    let isAdReady: Bool
    let isLoading: Bool
    let isWatchingAd: Bool
    let action: () -> Void
    
    private var buttonState: ButtonState {
        if isWatchingAd {
            return .watching
        } else if isLoading {
            return .loading
        } else if isAdReady {
            return .ready
        } else {
            return .unavailable
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                
                Image(systemName: type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(buttonState.iconColor(for: type))
                
                Text(type.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if buttonState == .watching {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                } else {
                    Text(buttonState.buttonText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(buttonState.textColor)
                }
            }
            .frame(height: 85)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(buttonState.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(buttonState.borderColor, lineWidth: 1)
                    )
            )
        }
        .disabled(!buttonState.isEnabled)
        .scaleEffect(buttonState.isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: buttonState)
    }
    
    private enum ButtonState: Equatable {
        case ready
        case loading
        case watching
        case unavailable
        
        var buttonText: String {
            switch self {
            case .ready: return "Reklam İzle"
            case .loading: return "Yükleniyor..."
            case .watching: return "Reklam Gösteriliyor..."
            case .unavailable: return "Reklam Yok"
            }
        }
        
        func iconColor(for type: JokerType) -> Color {
            switch self {
            case .ready: return type.brightColor
            case .loading: return .gray
            case .watching: return type.brightColor.opacity(0.8)
            case .unavailable: return .gray
            }
        }
        
        var textColor: Color {
            switch self {
            case .ready: return .yellow
            case .loading: return .gray
            case .watching: return .yellow
            case .unavailable: return .red.opacity(0.7)
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .ready: return .yellow.opacity(0.15)
            case .loading: return .gray.opacity(0.1)
            case .watching: return .yellow.opacity(0.2)
            case .unavailable: return .red.opacity(0.1)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .ready: return .yellow.opacity(0.4)
            case .loading: return .gray.opacity(0.3)
            case .watching: return .yellow.opacity(0.5)
            case .unavailable: return .red.opacity(0.3)
            }
        }
        
        var isEnabled: Bool {
            switch self {
            case .ready: return true
            case .loading, .watching, .unavailable: return false
            }
        }
    }
}
