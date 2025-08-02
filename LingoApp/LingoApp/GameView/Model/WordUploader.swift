//
//  WordUploader.swift
//  LingoApp
//
//  Created by Zeynep Toy on 3.08.2025.
//


import Foundation
import FirebaseFirestore

class WordUploader {
    
    private let db = Firestore.firestore()
    
    // MARK: - Kelime Çekme Fonksiyonları
    
    /// Belirtilen uzunlukta rastgele bir kelime getirir
    func fetchRandomWord(length: Int, completion: @escaping (String?) -> Void) {
        // Parametre validasyonu
        guard length >= 4 && length <= 6 else {
            print("❌ Geçersiz kelime uzunluğu: \(length). 4-6 arası olmalı.")
            completion(nil)
            return
        }
        
        db.collection("words")
            .document("categories")
            .collection("words\(length)")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Kelime çekme hatası: \(error)")
                    completion(nil)
                    return
                }
                
                let words = snapshot?.documents.compactMap { doc in
                    doc.data()["word"] as? String
                } ?? []
                
                // Kelime bulunamadı kontrolü
                if words.isEmpty {
                    print("⚠️ \(length) harfli kelime bulunamadı")
                    completion(nil)
                } else {
                    completion(words.randomElement())
                }
            }
    }
    
    /// Belirtilen uzunlukta tüm kelimeleri getirir
    func fetchWords(length: Int, completion: @escaping ([String]) -> Void) {
        guard length >= 4 && length <= 6 else {
            print("❌ Geçersiz kelime uzunluğu: \(length). 4-6 arası olmalı.")
            completion([])
            return
        }
        
        db.collection("words")
            .document("categories")
            .collection("words\(length)")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Kelime çekme hatası: \(error)")
                    completion([])
                    return
                }
                
                let words = snapshot?.documents.compactMap { doc in
                    doc.data()["word"] as? String
                } ?? []
                
                print("✅ \(length) harfli \(words.count) kelime getirildi")
                completion(words)
            }
    }
    
    /// Performans için limit ile rastgele kelime çekme (büyük dataset'ler için)
    func fetchRandomWordOptimized(length: Int, completion: @escaping (String?) -> Void) {
        guard length >= 4 && length <= 6 else {
            completion(nil)
            return
        }
        
        // Rastgele document ID ile optimize edilmiş çekme
        db.collection("words")
            .document("categories")
            .collection("words\(length)")
            .limit(to: 50) // İlk 50 kelimeyi al
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Kelime çekme hatası: \(error)")
                    completion(nil)
                    return
                }
                
                let words = snapshot?.documents.compactMap { doc in
                    doc.data()["word"] as? String
                } ?? []
                
                completion(words.randomElement())
            }
    }
    
    // MARK: - Async/Await Versiyon
    
    func fetchWordsAsync(length: Int) async throws -> [String] {
        guard length >= 4 && length <= 6 else {
            throw WordError.invalidLength
        }
        
        let snapshot = try await db.collection("words")
            .document("categories")
            .collection("words\(length)")
            .getDocuments()
        
        let words = snapshot.documents.compactMap { doc in
            doc.data()["word"] as? String
        }
        
        print("✅ \(length) harfli \(words.count) kelime getirildi (async)")
        return words
    }
    
    func fetchRandomWordAsync(length: Int) async throws -> String? {
        let words = try await fetchWordsAsync(length: length)
        return words.randomElement()
    }
    
    // MARK: - Kelime Validation
    
    /// Kelimenin veritabanında olup olmadığını kontrol eder
    func isValidWord(_ word: String, completion: @escaping (Bool) -> Void) {
        let length = word.count
        guard length >= 4 && length <= 6 else {
            completion(false)
            return
        }
        
        db.collection("words")
            .document("categories")
            .collection("words\(length)")
            .whereField("word", isEqualTo: word.turkishLowercased) // ✅ Türkçe küçük harf
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Kelime doğrulama hatası: \(error)")
                    completion(false)
                    return
                }
                
                let isValid = !(snapshot?.documents.isEmpty ?? true)
                print("✅ Kelime doğrulama: '\(word)' -> \(isValid)")
                completion(isValid)
            }
    }
    
    /// Async/await version of word validation
    func isValidWordAsync(_ word: String) async throws -> Bool {
        let length = word.count
        guard length >= 4 && length <= 6 else {
            return false
        }
        
        let snapshot = try await db.collection("words")
            .document("categories")
            .collection("words\(length)")
            .whereField("word", isEqualTo: word.turkishLowercased) // ✅ Türkçe küçük harf
            .getDocuments()
        
        let isValid = !snapshot.documents.isEmpty
        print("✅ Kelime doğrulama (async): '\(word)' -> \(isValid)")
        return isValid
    }
    
    // MARK: - Statistics
    
    /// Veritabanındaki kelime istatistiklerini getirir
    func getWordStatistics(completion: @escaping ([Int: Int]) -> Void) {
        var stats: [Int: Int] = [:]
        let group = DispatchGroup()
        
        for length in 4...6 {
            group.enter()
            db.collection("words")
                .document("categories")
                .collection("words\(length)")
                .getDocuments { snapshot, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("❌ İstatistik hatası (\(length) harf): \(error)")
                        stats[length] = 0
                    } else {
                        stats[length] = snapshot?.documents.count ?? 0
                    }
                }
        }
        
        group.notify(queue: .main) {
            completion(stats)
        }
    }
}

// MARK: - Error Handling
enum WordError: Error, LocalizedError {
    case invalidLength
    case noWordsFound
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidLength:
            return "Kelime uzunluğu 4-6 arasında olmalıdır"
        case .noWordsFound:
            return "Belirtilen uzunlukta kelime bulunamadı"
        case .networkError:
            return "Ağ bağlantısı hatası"
        }
    }
}

// MARK: - Singleton Pattern (Opsiyonel)
extension WordUploader {
    static let shared = WordUploader()
}

// MARK: - SwiftUI için ObservableObject
import Combine

class WordManager: ObservableObject {
    @Published var currentWord: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let wordUploader = WordUploader()
    
    func loadRandomWord(length: Int) {
        isLoading = true
        errorMessage = ""
        
        wordUploader.fetchRandomWord(length: length) { [weak self] word in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let word = word {
                    self?.currentWord = word.uppercased()
                } else {
                    self?.errorMessage = "Kelime yüklenemedi"
                }
            }
        }
    }
    
    func validateWord(_ guess: String, completion: @escaping (Bool) -> Void) {
        wordUploader.isValidWord(guess) { isValid in
            DispatchQueue.main.async {
                completion(isValid)
            }
        }
    }
}
