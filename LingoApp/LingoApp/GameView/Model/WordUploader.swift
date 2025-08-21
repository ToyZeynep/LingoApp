//
//  WordUploader.swift
//  LingoApp
//
//  Created by Zeynep Toy on 21.08.2025.
//

import Foundation

struct WordData: Decodable {
    let word: String
    let mean: String
}


class WordUploader {
    
    static let shared = WordUploader()
    
    private var turkishWords: [Int: [WordData]] = [:]
    private var englishWords: [Int: [WordData]] = [:]
    
    private init() {
        loadAll()
    }
    
    private func loadAll() {
        turkishWords[4] = loadWords(from: "word4")
        turkishWords[5] = loadWords(from: "word5")
        turkishWords[6] = loadWords(from: "word6")
        
        englishWords[4] = loadWords(from: "EnWords4")
        englishWords[5] = loadWords(from: "EnWords5")
        englishWords[6] = loadWords(from: "EnWords6")
    }
    
    private func loadWords(from resource: String) -> [WordData] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("❌ \(resource).json bulunamadı")
            return []
        }
        do {
            let decoded = try JSONDecoder().decode([WordData].self, from: data)
            print("✅ \(resource).json yüklenip \(decoded.count) kelime okundu")
            return decoded
        } catch {
            print("❌ \(resource).json decode hatası: \(error)")
            return []
        }
    }
    
    // MARK: - Random Kelime
    
    func fetchRandomTurkishWord(length: Int) -> WordData? {
        guard let list = turkishWords[length], !list.isEmpty else {
            print("⚠️ \(length) harfli Türkçe kelime bulunamadı")
            return nil
        }
        return list.randomElement()
    }
    
    func fetchRandomEnglishWord(length: Int) -> WordData? {
        guard let list = englishWords[length], !list.isEmpty else {
            print("⚠️ \(length) harfli İngilizce kelime bulunamadı")
            return nil
        }
        return list.randomElement()
    }
    
    // MARK: - Validasyon
    
    func isValidTurkishWord(_ word: String) -> Bool {
        let length = word.count
        guard let list = turkishWords[length] else { return false }
        return list.contains { $0.word.lowercased() == word.lowercased() }
    }
    
    func isValidEnglishWord(_ word: String) -> Bool {
        let length = word.count
        guard let list = englishWords[length] else { return false }
        return list.contains { $0.word.lowercased() == word.lowercased() }
    }
    
    // MARK: - Statistik
    
    func statistics() -> (tr: [Int: Int], en: [Int: Int]) {
        let trStats = turkishWords.mapValues { $0.count }
        let enStats = englishWords.mapValues { $0.count }
        return (trStats, enStats)
    }
}
