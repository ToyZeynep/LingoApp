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
    case showHint = "show_hint"
    case extraTime = "extra_time"
    
    var title: String {
        switch self {
        case .revealLetter:
            return "Harf Göster"
        case .removeLetter:
            return "Harf Sil"
        case .showHint:
            return "İpucu"
        case .extraTime:
            return "Ekstra Süre"
        }
    }
    
    var icon: String {
        switch self {
        case .revealLetter:
            return "lightbulb.fill"
        case .removeLetter:
            return "xmark.circle.fill"
        case .showHint:
            return "questionmark.circle.fill"
        case .extraTime:
            return "clock.arrow.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .revealLetter:
            return .yellow.opacity(0.95)
        case .removeLetter:
            return .red.opacity(0.9)
        case .showHint:
            return .blue.opacity(0.9)
        case .extraTime:
            return .green.opacity(0.9)
        }
    }
    
    var brightColor: Color {
        switch self {
        case .revealLetter:
            return .yellow
        case .removeLetter:
            return .red
        case .showHint:
            return .blue
        case .extraTime:
            return .green
        }
    }
    
    var description: String {
        switch self {
        case .revealLetter:
            return "Doğru bir harfi gösterir"
        case .removeLetter:
            return "Yanlış harfleri klavyeden kaldırır"
        case .showHint:
            return "Kelimenin anlamını gösterir"
        case .extraTime:
            return "30 saniye ekstra süre verir"
        }
    }
}

// MARK: - Joker Verisi
struct JokerData: Codable {
    var revealLetter: Int = 3
    var removeLetter: Int = 2
    var showHint: Int = 2
    var extraTime: Int = 2
    
    mutating func use(_ type: JokerType) -> Bool {
        switch type {
        case .revealLetter:
            if revealLetter > 0 {
                revealLetter -= 1
                return true
            }
        case .removeLetter:
            if removeLetter > 0 {
                removeLetter -= 1
                return true
            }
        case .showHint:
            if showHint > 0 {
                showHint -= 1
                return true
            }
        case .extraTime:
            if extraTime > 0 {
                extraTime -= 1
                return true
            }
        }
        return false
    }
    
    mutating func add(_ type: JokerType, count: Int = 1) {
        switch type {
        case .revealLetter:
            revealLetter += count
        case .removeLetter:
            removeLetter += count
        case .showHint:
            showHint += count
        case .extraTime:
            extraTime += count
        }
    }
    
    func count(for type: JokerType) -> Int {
        switch type {
        case .revealLetter:
            return revealLetter
        case .removeLetter:
            return removeLetter
        case .showHint:
            return showHint
        case .extraTime:
            return extraTime
        }
    }
}

// MARK: - Joker Manager
class JokerManager: ObservableObject {
    @Published var jokers = JokerData()
    @Published var usedJokersInCurrentGame: Set<JokerType> = []
    @Published var revealedLetters: Set<Int> = []
    @Published var removedLetters: Set<Character> = []
    @Published var currentHint: String = ""
    @Published var showHintPopup = false
    
    private let userDefaults = UserDefaults.standard
    private let jokersKey = "SavedJokers"
    
    init() {
        loadJokers()
    }
    
    // MARK: - Kayıt/Yükleme
    func saveJokers() {
        if let encoded = try? JSONEncoder().encode(jokers) {
            userDefaults.set(encoded, forKey: jokersKey)
        }
    }
    
    private func loadJokers() {
        if let data = userDefaults.data(forKey: jokersKey),
           let decoded = try? JSONDecoder().decode(JokerData.self, from: data) {
            jokers = decoded
        }
    }
    
    // MARK: - Joker Kullanımı
    func useJoker(_ type: JokerType, targetWord: String, gameModel: GameModel) -> Bool {
        guard jokers.use(type) else { return false }
        
        usedJokersInCurrentGame.insert(type)
        
        switch type {
        case .revealLetter:
            revealRandomLetter(in: targetWord)
        case .removeLetter:
            removeWrongLetters(targetWord: targetWord, gameModel: gameModel)
        case .showHint:
            showHint(for: targetWord)
        case .extraTime:
            gameModel.addExtraTime(30) // 30 saniye ekle
        }
        
        saveJokers()
        return true
    }
    
    private func revealRandomLetter(in word: String) {
        let availablePositions = (0..<word.count).filter { !revealedLetters.contains($0) }
        if let randomPosition = availablePositions.randomElement() {
            revealedLetters.insert(randomPosition)
        }
    }
    
    private func removeWrongLetters(targetWord: String, gameModel: GameModel) {
        let alphabet = "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ"
        let targetLetters = Set(targetWord)
        
        for char in alphabet {
            if !targetLetters.contains(char) {
                removedLetters.insert(char)
            }
        }
    }
    
    private func showHint(for word: String) {
        // Basit ipucu sistemi - gerçek uygulamada sözlük API'si kullanılabilir
        let hints: [String: String] = [
            "ELMAS": "Çok değerli, parlak taş",
            "KITAP": "Okumak için kullanılan nesne",
            "BAHÇE": "Çiçek ve bitkilerin yetiştirildiği yer",
            "ÇEVRE": "Etrafımızda bulunan ortam",
            "DÜNYA": "Yaşadığımız gezegen",
            "GÜNEŞ": "Gündüz ışık veren yıldız",
            "DENIZ": "Büyük tuzlu su kütlesi",
            "ORMAN": "Ağaçların yoğun olduğu alan"
        ]
        
        currentHint = hints[word] ?? "Bu kelime hakkında ipucu bulunamadı"
        showHintPopup = true
    }
    
    // MARK: - Oyun Sıfırlama
    func resetForNewGame() {
        usedJokersInCurrentGame.removeAll()
        revealedLetters.removeAll()
        removedLetters.removeAll()
        currentHint = ""
        showHintPopup = false
    }
    
    // MARK: - Reklam ile Joker Kazanma
    func earnJokersFromAd() {
        // Reklam izlendikten sonra joker ver
        let randomJoker = JokerType.allCases.randomElement() ?? .revealLetter
        jokers.add(randomJoker, count: 1)
        saveJokers()
    }
    
    func earnDailyJokers() {
        // Günlük joker dağıtımı
        jokers.add(.revealLetter, count: 1)
        jokers.add(.removeLetter, count: 1)
        saveJokers()
    }
}
