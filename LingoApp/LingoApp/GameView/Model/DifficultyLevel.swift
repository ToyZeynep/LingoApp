//
//  DifficultyLevel.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

enum DifficultyLevel: String, CaseIterable, Codable {
    
    case easy = "4_letter"
    case medium = "5_letter"
    case hard = "6_letter"
    
    var wordLength: Int {
        switch self {
        case .easy: return 4
        case .medium: return 5
        case .hard: return 6
        }
    }
    
    var title: String {
        switch self {
        case .easy: return "ACEMİ".localized
        case .medium: return "ORTA".localized
        case .hard: return "UZMAN".localized
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "4 harfli kelimeler\nAcemiler için".localized
        case .medium: return "5 harfli kelimeler\nKlasik mod".localized
        case .hard: return "6 harfli kelimeler\nUzmanlar için".localized
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .easy: return [.mint, .green.opacity(0.7)]
        case .medium: return [.orange, .red.opacity(0.8)]
        case .hard: return [.purple, .indigo.opacity(0.8)]
        }
    }
    
    var time: Int {
        switch self {
        case .easy: return 150
        case .medium: return 120
        case .hard: return 120
        }
    }
    
    var maxGuesses: Int {
        switch self {
        case .easy: return 6
        case .medium: return 6
        case .hard: return 6
            
        }
    }
    
    var emoji: String {
        switch self {
        case .easy:
            return "🌱"
        case .medium:
            return "🔥"
        case .hard:
            return "⚡"
        }
    }
    
    var color: Color {
        switch self {
        case .easy:
            return .mint
        case .medium:
            return .orange
        case .hard:
            return .purple
        }
    }
    
    var visibleGuesses: Int {
        switch self {
        case .easy: return 5
        case .medium: return 5
        case .hard: return 5
        }
    }
}
