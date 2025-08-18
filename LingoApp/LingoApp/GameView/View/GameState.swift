//
//  GameState.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import Foundation

enum GameState {
    case playing
    case won
    case lost
}

enum LetterGuessState {
    case correct
    case wrongPosition
    case wrong
    case unused
    case revealed
}

struct GuessResult {
    let word: String
    let letters: [LetterState]
}

struct LetterState {
    let letter: Character
    let state: LetterGuessState
}

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
