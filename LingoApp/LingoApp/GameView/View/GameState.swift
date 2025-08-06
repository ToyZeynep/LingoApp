//
//  GameState.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import Foundation

// MARK: - Oyun Durumları
enum GameState {
    case playing
    case won
    case lost
}

enum LetterGuessState {
    case correct      // Doğru harf, doğru konum (yeşil)
    case wrongPosition // Doğru harf, yanlış konum (sarı)
    case wrong        // Yanlış harf (gri)
    case unused       // Henüz kullanılmamış
    case revealed
}

// MARK: - Veri Modelleri
struct GuessResult {
    let word: String
    let letters: [LetterState]
}

struct LetterState {
    let letter: Character
    let state: LetterGuessState
}

// MARK: - Oyun İstatistikleri
struct GameStatistics: Codable {
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var currentStreak: Int = 0
    var maxStreak: Int = 0
    var guessDistribution: [Int: Int] = [:]
    
    var winPercentage: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100
    }
}
