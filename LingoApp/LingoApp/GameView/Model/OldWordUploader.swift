////
////  WordUploader.swift
////  LingoApp
////
////  Created by Zeynep Toy on 3.08.2025.
////
//
//import Foundation
//import FirebaseFirestore
//
//class WordUploaderOLD {
//    
//    private let db = Firestore.firestore()
//    
//    // MARK: - Collection References
//    
//    /// Anlamlı kelimeler collection'ı (JSON'dan yüklenen)
//    private func wordsWithMeaningsCollection(length: Int) -> CollectionReference {
//        return db.collection("words_with_meanings")
//            .document("categories")
//            .collection("words\(length)")
//    }
//    
//    /// Sadece kelimeler collection'ı (TXT'den yüklenen - eski)
//    private func wordsOnlyCollection(length: Int) -> CollectionReference {
//        return db.collection("words")
//            .document("categories")
//            .collection("words\(length)")
//    }
//    
//    // MARK: - Kelime Çekme Fonksiyonları
//    
//    /// Belirtilen uzunlukta rastgele bir kelime getirir (anlamıyla birlikte)
//    func fetchRandomWordWithMeaning(length: Int, completion: @escaping (WordData?) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion(nil)
//            return
//        }
//        
//        wordsWithMeaningsCollection(length: length)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Anlamlı kelime çekme hatası: \(error)")
//                    completion(nil)
//                    return
//                }
//                
//                let wordDataList = snapshot?.documents.compactMap { doc -> WordData? in
//                    let data = doc.data()
//                    guard let word = data["word"] as? String,
//                          let meaning = data["meaning"] as? String else {
//                        return nil
//                    }
//                    return WordData(word: word, meaning: meaning)
//                } ?? []
//                
//                if wordDataList.isEmpty {
//                    print("⚠️ \(length) harfli anlamlı kelime bulunamadı")
//                    completion(nil)
//                } else {
//                    let selectedWord = wordDataList.randomElement()!
//                    print("🎯 Çekilen Kelime: '\(selectedWord.word.uppercased())'")
//                    print("📖 Anlamı: \(selectedWord.meaning)")
//                    completion(selectedWord)
//                }
//            }
//    }
//    
//    /// Belirtilen uzunlukta rastgele bir kelime getirir (sadece kelime)
//    func fetchRandomWord(length: Int, completion: @escaping (String?) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion(nil)
//            return
//        }
//        
//        // Önce anlamlı kelimelerden dene
//        wordsWithMeaningsCollection(length: length)
//            .limit(to: 50) // Performance için limit
//            .getDocuments { [weak self] snapshot, error in
//                if let error = error {
//                    print("❌ Anlamlı kelime çekme hatası: \(error)")
//                    // Fallback: Eski collection'ı dene
//                    self?.fetchFromWordsOnlyCollection(length: length, completion: completion)
//                    return
//                }
//                
//                let words = snapshot?.documents.compactMap { doc in
//                    doc.data()["word"] as? String
//                } ?? []
//                
//                if words.isEmpty {
//                    print("⚠️ \(length) harfli anlamlı kelime bulunamadı, eski collection deneniyor...")
//                    // Fallback: Eski collection'ı dene
//                    self?.fetchFromWordsOnlyCollection(length: length, completion: completion)
//                } else {
//                    let selectedWord = words.randomElement()!
//                    print("🎯 Çekilen Kelime: '\(selectedWord.uppercased())' (\(length) harf)")
//                    print("📝 Kaynak: Anlamlı kelimeler collection'ı")
//                    completion(selectedWord)
//                }
//            }
//    }
//    
//    /// Eski collection'dan kelime çekme (fallback)
//    private func fetchFromWordsOnlyCollection(length: Int, completion: @escaping (String?) -> Void) {
//        wordsOnlyCollection(length: length)
//            .limit(to: 50)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Eski collection'dan kelime çekme hatası: \(error)")
//                    completion(nil)
//                    return
//                }
//                
//                let words = snapshot?.documents.compactMap { doc in
//                    doc.data()["word"] as? String
//                } ?? []
//                
//                if words.isEmpty {
//                    print("⚠️ \(length) harfli kelime hiçbir collection'da bulunamadı")
//                    completion(nil)
//                } else {
//                    let selectedWord = words.randomElement()!
//                    print("🎯 Çekilen Kelime: '\(selectedWord.uppercased())' (\(length) harf)")
//                    print("📝 Kaynak: Eski kelimeler collection'ı (fallback)")
//                    completion(selectedWord)
//                }
//            }
//    }
//    
//    /// Belirtilen uzunlukta tüm kelimeleri getirir (anlamlarıyla birlikte)
//    func fetchWordsWithMeanings(length: Int, completion: @escaping ([WordData]) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion([])
//            return
//        }
//        
//        wordsWithMeaningsCollection(length: length)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Anlamlı kelimeler çekme hatası: \(error)")
//                    completion([])
//                    return
//                }
//                
//                let wordDataList = snapshot?.documents.compactMap { doc -> WordData? in
//                    let data = doc.data()
//                    guard let word = data["word"] as? String,
//                          let meaning = data["meaning"] as? String else {
//                        return nil
//                    }
//                    return WordData(word: word, meaning: meaning)
//                } ?? []
//                
//                print("✅ \(length) harfli \(wordDataList.count) anlamlı kelime getirildi")
//                completion(wordDataList)
//            }
//    }
//    
//    /// Belirtilen uzunlukta tüm kelimeleri getirir (sadece kelimeler)
//    func fetchWords(length: Int, completion: @escaping ([String]) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion([])
//            return
//        }
//        
//        // Önce anlamlı kelimelerden dene
//        wordsWithMeaningsCollection(length: length)
//            .getDocuments { [weak self] snapshot, error in
//                if let error = error {
//                    print("❌ Anlamlı kelimeler çekme hatası: \(error)")
//                    // Fallback: Eski collection'ı dene
//                    self?.fetchFromWordsOnlyCollectionAll(length: length, completion: completion)
//                    return
//                }
//                
//                let words = snapshot?.documents.compactMap { doc in
//                    doc.data()["word"] as? String
//                } ?? []
//                
//                if words.isEmpty {
//                    print("⚠️ \(length) harfli anlamlı kelime bulunamadı, eski collection deneniyor...")
//                    // Fallback: Eski collection'ı dene
//                    self?.fetchFromWordsOnlyCollectionAll(length: length, completion: completion)
//                } else {
//                    print("✅ \(length) harfli \(words.count) kelime getirildi (anlamlı collection)")
//                    completion(words)
//                }
//            }
//    }
//    
//    /// Eski collection'dan tüm kelimeleri çekme (fallback)
//    private func fetchFromWordsOnlyCollectionAll(length: Int, completion: @escaping ([String]) -> Void) {
//        wordsOnlyCollection(length: length)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Eski collection'dan kelimeler çekme hatası: \(error)")
//                    completion([])
//                    return
//                }
//                
//                let words = snapshot?.documents.compactMap { doc in
//                    doc.data()["word"] as? String
//                } ?? []
//                
//                print("✅ \(length) harfli \(words.count) kelime getirildi (eski collection)")
//                completion(words)
//            }
//    }
//    
//    // MARK: - Async/Await Versions
//    
//    func fetchWordsWithMeaningsAsync(length: Int) async throws -> [WordData] {
//        guard length >= 4 && length <= 6 else {
//            throw WordError.invalidLength
//        }
//        
//        let snapshot = try await wordsWithMeaningsCollection(length: length)
//            .getDocuments()
//        
//        let wordDataList = snapshot.documents.compactMap { doc -> WordData? in
//            let data = doc.data()
//            guard let word = data["word"] as? String,
//                  let meaning = data["meaning"] as? String else {
//                return nil
//            }
//            return WordData(word: word, meaning: meaning)
//        }
//        
//        print("✅ \(length) harfli \(wordDataList.count) anlamlı kelime getirildi (async)")
//        return wordDataList
//    }
//    
//    func fetchWordsAsync(length: Int) async throws -> [String] {
//        guard length >= 4 && length <= 6 else {
//            throw WordError.invalidLength
//        }
//        
//        do {
//            // Önce anlamlı kelimelerden dene
//            let snapshot = try await wordsWithMeaningsCollection(length: length)
//                .getDocuments()
//            
//            let words = snapshot.documents.compactMap { doc in
//                doc.data()["word"] as? String
//            }
//            
//            if !words.isEmpty {
//                print("✅ \(length) harfli \(words.count) kelime getirildi (anlamlı collection - async)")
//                return words
//            }
//        } catch {
//            print("❌ Anlamlı kelimeler çekme hatası (async): \(error)")
//        }
//        
//        // Fallback: Eski collection
//        let snapshot = try await wordsOnlyCollection(length: length)
//            .getDocuments()
//        
//        let words = snapshot.documents.compactMap { doc in
//            doc.data()["word"] as? String
//        }
//        
//        print("✅ \(length) harfli \(words.count) kelime getirildi (eski collection - async)")
//        return words
//    }
//    
//    func fetchRandomWordWithMeaningAsync(length: Int) async throws -> WordData? {
//        let words = try await fetchWordsWithMeaningsAsync(length: length)
//        if let selectedWord = words.randomElement() {
//            print("🎯 Çekilen Kelime (Async): '\(selectedWord.word.uppercased())'")
//            print("📖 Anlamı: \(selectedWord.meaning)")
//            return selectedWord
//        }
//        return nil
//    }
//    
//    func fetchRandomWordAsync(length: Int) async throws -> String? {
//        let words = try await fetchWordsAsync(length: length)
//        if let selectedWord = words.randomElement() {
//            print("🎯 Çekilen Kelime (Async): '\(selectedWord.uppercased())' (\(length) harf)")
//            return selectedWord
//        }
//        return nil
//    }
//    
//    // MARK: - Kelime Validation
//    
//    /// Kelimenin veritabanında olup olmadığını kontrol eder (her iki collection'da da arar)
//    func isValidWord(_ word: String, completion: @escaping (Bool) -> Void) {
//        let length = word.count
//        guard length >= 4 && length <= 6 else {
//            completion(false)
//            return
//        }
//        
//        let lowercasedWord = word.turkishLowercased
//        
//        // Önce anlamlı kelimeler collection'ında ara
//        wordsWithMeaningsCollection(length: length)
//            .whereField("word", isEqualTo: lowercasedWord)
//            .getDocuments { [weak self] snapshot, error in
//                if let error = error {
//                    print("❌ Anlamlı kelimeler'de doğrulama hatası: \(error)")
//                    // Fallback: Eski collection'ı dene
//                    self?.validateInWordsOnlyCollection(lowercasedWord, length: length, completion: completion)
//                    return
//                }
//                
//                let isValid = !(snapshot?.documents.isEmpty ?? true)
//                if isValid {
//                    print("✅ Kelime doğrulama: '\(word)' -> \(isValid) (anlamlı collection)")
//                    completion(true)
//                } else {
//                    // Fallback: Eski collection'ı dene
//                    self?.validateInWordsOnlyCollection(lowercasedWord, length: length, completion: completion)
//                }
//            }
//    }
//    
//    /// Eski collection'da kelime doğrulama (fallback)
//    private func validateInWordsOnlyCollection(_ word: String, length: Int, completion: @escaping (Bool) -> Void) {
//        wordsOnlyCollection(length: length)
//            .whereField("word", isEqualTo: word)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ Eski collection'da doğrulama hatası: \(error)")
//                    completion(false)
//                    return
//                }
//                
//                let isValid = !(snapshot?.documents.isEmpty ?? true)
//                print("✅ Kelime doğrulama: '\(word)' -> \(isValid) (eski collection)")
//                completion(isValid)
//            }
//    }
//    
//    /// Async/await version of word validation
//    func isValidWordAsync(_ word: String) async throws -> Bool {
//        let length = word.count
//        guard length >= 4 && length <= 6 else {
//            return false
//        }
//        
//        let lowercasedWord = word.turkishLowercased
//        
//        // Önce anlamlı kelimeler collection'ında ara
//        do {
//            let snapshot = try await wordsWithMeaningsCollection(length: length)
//                .whereField("word", isEqualTo: lowercasedWord)
//                .getDocuments()
//            
//            if !snapshot.documents.isEmpty {
//                print("✅ Kelime doğrulama (async): '\(word)' -> true (anlamlı collection)")
//                return true
//            }
//        } catch {
//            print("❌ Anlamlı collection'da doğrulama hatası (async): \(error)")
//        }
//        
//        // Fallback: Eski collection
//        do {
//            let snapshot = try await wordsOnlyCollection(length: length)
//                .whereField("word", isEqualTo: lowercasedWord)
//                .getDocuments()
//            
//            let isValid = !snapshot.documents.isEmpty
//            print("✅ Kelime doğrulama (async): '\(word)' -> \(isValid) (eski collection)")
//            return isValid
//        } catch {
//            print("❌ Eski collection'da doğrulama hatası (async): \(error)")
//            return false
//        }
//    }
//    
//    // MARK: - Statistics
//    
//    /// Veritabanındaki kelime istatistiklerini getirir
//    func getWordStatistics(completion: @escaping (WordStatistics) -> Void) {
//        var meaningfulStats: [Int: Int] = [:]
//        var simpleStats: [Int: Int] = [:]
//        let group = DispatchGroup()
//        
//        // Anlamlı kelimeler istatistikleri
//        for length in 4...6 {
//            group.enter()
//            wordsWithMeaningsCollection(length: length)
//                .getDocuments { snapshot, error in
//                    defer { group.leave() }
//                    
//                    if let error = error {
//                        print("❌ Anlamlı kelimeler istatistik hatası (\(length) harf): \(error)")
//                        meaningfulStats[length] = 0
//                    } else {
//                        meaningfulStats[length] = snapshot?.documents.count ?? 0
//                    }
//                }
//        }
//        
//        // Eski collection istatistikleri
//        for length in 4...6 {
//            group.enter()
//            wordsOnlyCollection(length: length)
//                .getDocuments { snapshot, error in
//                    defer { group.leave() }
//                    
//                    if let error = error {
//                        print("❌ Eski collection istatistik hatası (\(length) harf): \(error)")
//                        simpleStats[length] = 0
//                    } else {
//                        simpleStats[length] = snapshot?.documents.count ?? 0
//                    }
//                }
//        }
//        
//        group.notify(queue: .main) {
//            let statistics = WordStatistics(
//                wordsWithMeanings: meaningfulStats,
//                wordsOnly: simpleStats
//            )
//            completion(statistics)
//        }
//    }
//}
//
//// MARK: - Data Models
//
//struct WordData {
//    let word: String
//    let meaning: String
//}
//
//struct WordStatistics {
//    let wordsWithMeanings: [Int: Int] // [uzunluk: sayı]
//    let wordsOnly: [Int: Int]         // [uzunluk: sayı]
//    
//    var totalWordsWithMeanings: Int {
//        wordsWithMeanings.values.reduce(0, +)
//    }
//    
//    var totalWordsOnly: Int {
//        wordsOnly.values.reduce(0, +)
//    }
//    
//    var grandTotal: Int {
//        totalWordsWithMeanings + totalWordsOnly
//    }
//}
//
//// MARK: - Error Handling
//enum WordError: Error, LocalizedError {
//    case invalidLength
//    case noWordsFound
//    case networkError
//    
//    var errorDescription: String? {
//        switch self {
//        case .invalidLength:
//            return "Kelime uzunluğu 4-6 arasında olmalıdır"
//        case .noWordsFound:
//            return "Belirtilen uzunlukta kelime bulunamadı"
//        case .networkError:
//            return "Ağ bağlantısı hatası"
//        }
//    }
//}
//
//// MARK: - Singleton Pattern
//extension WordUploader {
//    static let shared = WordUploader()
//}
//
//// MARK: - SwiftUI için ObservableObject
//import Combine
//
//class WordManager: ObservableObject {
//    @Published var currentWord: String = ""
//    @Published var currentWordWithMeaning: WordData?
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String = ""
//    @Published var statistics: WordStatistics?
//    
//    private let wordUploader = WordUploader()
//    
//    /// Rastgele kelime yükle (sadece kelime)
//    func loadRandomWord(length: Int) {
//        isLoading = true
//        errorMessage = ""
//        
//        wordUploader.fetchRandomWord(length: length) { [weak self] word in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                if let word = word {
//                    self?.currentWord = word.uppercased()
//                } else {
//                    self?.errorMessage = "Kelime yüklenemedi"
//                }
//            }
//        }
//    }
//    
//    /// Rastgele kelime yükle (anlamıyla birlikte)
//    func loadRandomWordWithMeaning(length: Int) {
//        isLoading = true
//        errorMessage = ""
//        
//        wordUploader.fetchRandomWordWithMeaning(length: length) { [weak self] wordData in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                if let wordData = wordData {
//                    self?.currentWordWithMeaning = wordData
//                    self?.currentWord = wordData.word.uppercased()
//                    
//                    // Console'a yazdır
//                    print("🎯 UI'a Yüklenen Kelime: '\(wordData.word.uppercased())'")
//                    print("📖 Anlamı: \(wordData.meaning)")
//                } else {
//                    self?.errorMessage = "Anlamlı kelime yüklenemedi"
//                    print("❌ UI'a kelime yüklenemedi")
//                }
//            }
//        }
//    }
//    
//    /// Kelime doğrulama
//    func validateWord(_ guess: String, completion: @escaping (Bool) -> Void) {
//        wordUploader.isValidWord(guess) { isValid in
//            DispatchQueue.main.async {
//                completion(isValid)
//            }
//        }
//    }
//    
//    /// İstatistikleri yükle
//    func loadStatistics() {
//        wordUploader.getWordStatistics { [weak self] stats in
//            DispatchQueue.main.async {
//                self?.statistics = stats
//            }
//        }
//    }
//}
//
//// MARK: - English Words Extension
//extension WordUploader {
//    
//    /// İngilizce kelimeler collection'ı
//    private func englishWordsCollection(length: Int) -> CollectionReference {
//        return db.collection("english_words")
//            .document("categories")
//            .collection("words\(length)")
//    }
//    
//    // MARK: - English Word Methods (Same as Turkish)
//    
//    /// Belirtilen uzunlukta rastgele İngilizce kelime getirir (anlamıyla birlikte)
//    func fetchRandomEnglishWordWithMeaning(length: Int, completion: @escaping (WordData?) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz İngilizce kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion(nil)
//            return
//        }
//        
//        englishWordsCollection(length: length)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ İngilizce kelime çekme hatası: \(error)")
//                    completion(nil)
//                    return
//                }
//                
//                let wordDataList = snapshot?.documents.compactMap { doc -> WordData? in
//                    let data = doc.data()
//                    guard let word = data["word"] as? String else {
//                        return nil
//                    }
//                    let meaning = data["meaning"] as? String ?? ""
//                    return WordData(word: word, meaning: meaning)
//                } ?? []
//                
//                if wordDataList.isEmpty {
//                    print("⚠️ \(length) harfli İngilizce kelime bulunamadı")
//                    completion(nil)
//                } else {
//                    let selectedWord = wordDataList.randomElement()!
//                    print("🎯 Çekilen İngilizce Kelime: '\(selectedWord.word.uppercased())'")
//                    print("📖 Anlamı: \(selectedWord.meaning)")
//                    completion(selectedWord)
//                }
//            }
//    }
//    
//    /// Belirtilen uzunlukta rastgele İngilizce kelime getirir (sadece kelime)
//    func fetchRandomEnglishWord(length: Int, completion: @escaping (String?) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz İngilizce kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion(nil)
//            return
//        }
//        
//        englishWordsCollection(length: length)
//            .limit(to: 50)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ İngilizce kelime çekme hatası: \(error)")
//                    completion(nil)
//                    return
//                }
//                
//                let words = snapshot?.documents.compactMap { doc in
//                    doc.data()["word"] as? String
//                } ?? []
//                
//                if words.isEmpty {
//                    print("⚠️ \(length) harfli İngilizce kelime bulunamadı")
//                    completion(nil)
//                } else {
//                    let selectedWord = words.randomElement()!
//                    print("🎯 Çekilen İngilizce Kelime: '\(selectedWord.uppercased())' (\(length) harf)")
//                    print("📝 Kaynak: İngilizce kelimeler collection'ı")
//                    completion(selectedWord)
//                }
//            }
//    }
//    
//    /// Belirtilen uzunlukta tüm İngilizce kelimeleri getirir (anlamlarıyla birlikte)
//    func fetchEnglishWordsWithMeanings(length: Int, completion: @escaping ([WordData]) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz İngilizce kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion([])
//            return
//        }
//        
//        englishWordsCollection(length: length)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ İngilizce kelimeler çekme hatası: \(error)")
//                    completion([])
//                    return
//                }
//                
//                let wordDataList = snapshot?.documents.compactMap { doc -> WordData? in
//                    let data = doc.data()
//                    guard let word = data["word"] as? String else {
//                        return nil
//                    }
//                    let meaning = data["meaning"] as? String ?? ""
//                    return WordData(word: word, meaning: meaning)
//                } ?? []
//                
//                print("✅ \(length) harfli \(wordDataList.count) İngilizce kelime getirildi")
//                completion(wordDataList)
//            }
//    }
//    
//    /// Belirtilen uzunlukta tüm İngilizce kelimeleri getirir (sadece kelimeler)
//    func fetchEnglishWords(length: Int, completion: @escaping ([String]) -> Void) {
//        guard length >= 4 && length <= 6 else {
//            print("❌ Geçersiz İngilizce kelime uzunluğu: \(length). 4-6 arası olmalı.")
//            completion([])
//            return
//        }
//        
//        englishWordsCollection(length: length)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ İngilizce kelimeler çekme hatası: \(error)")
//                    completion([])
//                    return
//                }
//                
//                let words = snapshot?.documents.compactMap { doc in
//                    doc.data()["word"] as? String
//                } ?? []
//                
//                print("✅ \(length) harfli \(words.count) İngilizce kelime getirildi")
//                completion(words)
//            }
//    }
//    
//    // MARK: - English Words Async/Await
//    
//    func fetchEnglishWordsWithMeaningsAsync(length: Int) async throws -> [WordData] {
//        guard length >= 4 && length <= 6 else {
//            throw WordError.invalidLength
//        }
//        
//        let snapshot = try await englishWordsCollection(length: length)
//            .getDocuments()
//        
//        let wordDataList = snapshot.documents.compactMap { doc -> WordData? in
//            let data = doc.data()
//            guard let word = data["word"] as? String else {
//                return nil
//            }
//            let meaning = data["meaning"] as? String ?? ""
//            return WordData(word: word, meaning: meaning)
//        }
//        
//        print("✅ \(length) harfli \(wordDataList.count) İngilizce kelime getirildi (async)")
//        return wordDataList
//    }
//    
//    func fetchEnglishWordsAsync(length: Int) async throws -> [String] {
//        guard length >= 4 && length <= 6 else {
//            throw WordError.invalidLength
//        }
//        
//        let snapshot = try await englishWordsCollection(length: length)
//            .getDocuments()
//        
//        let words = snapshot.documents.compactMap { doc in
//            doc.data()["word"] as? String
//        }
//        
//        print("✅ \(length) harfli \(words.count) İngilizce kelime getirildi (async)")
//        return words
//    }
//    
//    func fetchRandomEnglishWordWithMeaningAsync(length: Int) async throws -> WordData? {
//        let words = try await fetchEnglishWordsWithMeaningsAsync(length: length)
//        if let selectedWord = words.randomElement() {
//            print("🎯 Çekilen İngilizce Kelime (Async): '\(selectedWord.word.uppercased())'")
//            print("📖 Anlamı: \(selectedWord.meaning)")
//            return selectedWord
//        }
//        return nil
//    }
//    
//    func fetchRandomEnglishWordAsync(length: Int) async throws -> String? {
//        let words = try await fetchEnglishWordsAsync(length: length)
//        if let selectedWord = words.randomElement() {
//            print("🎯 Çekilen İngilizce Kelime (Async): '\(selectedWord.uppercased())' (\(length) harf)")
//            return selectedWord
//        }
//        return nil
//    }
//    
//    // MARK: - English Word Validation
//    
//    /// İngilizce kelimenin veritabanında olup olmadığını kontrol eder
//    func isValidEnglishWord(_ word: String, completion: @escaping (Bool) -> Void) {
//        let length = word.count
//        guard length >= 4 && length <= 6 else {
//            completion(false)
//            return
//        }
//        
//        let lowercasedWord = word.lowercased()
//        
//        englishWordsCollection(length: length)
//            .whereField("word", isEqualTo: lowercasedWord)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("❌ İngilizce kelime doğrulama hatası: \(error)")
//                    completion(false)
//                    return
//                }
//                
//                let isValid = !(snapshot?.documents.isEmpty ?? true)
//                print("✅ İngilizce kelime doğrulama: '\(word)' -> \(isValid)")
//                completion(isValid)
//            }
//    }
//    
//    /// Async/await version of English word validation
//    func isValidEnglishWordAsync(_ word: String) async throws -> Bool {
//        let length = word.count
//        guard length >= 4 && length <= 6 else {
//            return false
//        }
//        
//        let lowercasedWord = word.lowercased()
//        
//        let snapshot = try await englishWordsCollection(length: length)
//            .whereField("word", isEqualTo: lowercasedWord)
//            .getDocuments()
//        
//        let isValid = !snapshot.documents.isEmpty
//        print("✅ İngilizce kelime doğrulama (async): '\(word)' -> \(isValid)")
//        return isValid
//    }
//}
//
//// MARK: - WordManager English Extensions
//extension WordManager {
//    
//    func loadRandomEnglishWord(length: Int) {
//        isLoading = true
//        errorMessage = ""
//        
//        wordUploader.fetchRandomEnglishWord(length: length) { [weak self] word in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                if let word = word {
//                    self?.currentWord = word.uppercased()
//                } else {
//                    self?.errorMessage = "İngilizce kelime yüklenemedi"
//                }
//            }
//        }
//    }
//    
//    /// Rastgele İngilizce kelime yükle (anlamıyla birlikte)
//    func loadRandomEnglishWordWithMeaning(length: Int) {
//        isLoading = true
//        errorMessage = ""
//        
//        wordUploader.fetchRandomEnglishWordWithMeaning(length: length) { [weak self] wordData in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                if let wordData = wordData {
//                    self?.currentWordWithMeaning = wordData
//                    self?.currentWord = wordData.word.uppercased()
//                    
//                    // Console'a yazdır
//                    print("🎯 UI'a Yüklenen İngilizce Kelime: '\(wordData.word.uppercased())'")
//                    print("📖 Anlamı: \(wordData.meaning)")
//                } else {
//                    self?.errorMessage = "Anlamlı İngilizce kelime yüklenemedi"
//                    print("❌ UI'a İngilizce kelime yüklenemedi")
//                }
//            }
//        }
//    }
//    
//    /// İngilizce kelime doğrulama
//    func validateEnglishWord(_ guess: String, completion: @escaping (Bool) -> Void) {
//        wordUploader.isValidEnglishWord(guess) { isValid in
//            DispatchQueue.main.async {
//                completion(isValid)
//            }
//        }
//    }
//}
