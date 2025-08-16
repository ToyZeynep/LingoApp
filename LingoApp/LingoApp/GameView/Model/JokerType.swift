//
//  JokerType.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import Foundation
import SwiftUI

// MARK: - Joker Türleri
enum JokerType: String, CaseIterable, Codable {
    case revealLetter = "reveal_letter"
    case removeLetter = "remove_letter"
    case extraTime = "extra_time"
    case showHint = "show_hint"
    
    var title: String {
        switch self {
        case .revealLetter:
            return "Harf Göster"
        case .removeLetter:
            return "Harf Sil"
        case .extraTime:
            return "Ekstra Süre"
        case .showHint:
            return "İpucu Göster"
        }
    }
    
    var icon: String {
        switch self {
        case .revealLetter:
            return "lightbulb.fill"
        case .removeLetter:
            return "xmark.circle.fill"
        case .extraTime:
            return "clock.arrow.circlepath"
        case .showHint:
            return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .revealLetter:
            return .yellow.opacity(0.95)
        case .removeLetter:
            return .red.opacity(0.9)
        case .extraTime:
            return .green.opacity(0.9)
        case .showHint:
            return .blue.opacity(0.9)
        }
    }
    
    var brightColor: Color {
        switch self {
        case .revealLetter:
            return .yellow
        case .removeLetter:
            return .red
        case .extraTime:
            return .green
        case .showHint:
            return .blue
        }
    }
    
    var description: String {
        switch self {
        case .revealLetter:
            return "Doğru bir harfi gösterir"
        case .removeLetter:
            return "Yanlış harfleri klavyeden kaldırır"
        case .extraTime:
            return "30 saniye ekstra süre verir"
        case .showHint:
            return "Kelimenin anlamını gösterir"
        }
    }
}

// MARK: - Joker Stok Yönetimi
struct JokerStock: Codable {
    private var jokers: [JokerType: Int] = [:]
    
    init() {
        // Başlangıç jokerleri
        jokers[.revealLetter] = 2
        jokers[.removeLetter] = 2
        jokers[.extraTime] = 2
        jokers[.showHint] = 2
    }
    
    func count(for type: JokerType) -> Int {
        return jokers[type] ?? 0
    }
    
    mutating func add(_ type: JokerType, count: Int = 1) {
        jokers[type, default: 0] += count
    }
    
    mutating func use(_ type: JokerType) -> Bool {
        guard let current = jokers[type], current > 0 else {
            return false
        }
        jokers[type] = current - 1
        return true
    }
}

// MARK: - Joker Manager
class JokerManager: ObservableObject {
    @Published var jokers = JokerStock()
    @Published var revealedLetters: Set<Int> = []
    @Published var removedLetters: Set<Character> = []
    @Published var usedJokersInCurrentGame: Set<JokerType> = []
    
    init() {
        loadJokers()
    }
    
    // Joker ekleme (reklam izleme sonrası)
    func addJoker(_ type: JokerType, count: Int = 1) {
        jokers.add(type, count: count)
        saveJokers()
    }
    
    // Joker kullanımı kontrol
    func canUseJoker(_ type: JokerType) -> Bool {
        return jokers.count(for: type) > 0
    }
    
    // Yeni oyun başlarken temizlik
    func resetForNewGame() {
        revealedLetters.removeAll()
        removedLetters.removeAll()
        usedJokersInCurrentGame.removeAll()
    }
    
    // MARK: - Persistence
     func saveJokers() {
        if let encoded = try? JSONEncoder().encode(jokers) {
            UserDefaults.standard.set(encoded, forKey: "joker_stock")
        }
    }
    
    private func loadJokers() {
        if let data = UserDefaults.standard.data(forKey: "joker_stock"),
           let decoded = try? JSONDecoder().decode(JokerStock.self, from: data) {
            jokers = decoded
        }
    }
}
