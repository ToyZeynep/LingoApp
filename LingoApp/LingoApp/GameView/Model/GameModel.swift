//
//  GameModel.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import Foundation
import SwiftUI
import AVFoundation

class GameModel: ObservableObject {
    @Published var currentGuess = ""
    @Published var guesses: [GuessResult] = []
    @Published var gameState: GameState = .playing
    @Published var targetWord = ""
    @Published var showInvalidWordAlert = false
    @Published var jokerManager = JokerManager()
    @Published var timeRemaining: TimeInterval = 120
    @Published var isTimerActive = false
    @Published var soundEnabled = true // Ses ayarı eklendi
    
    var maxGuesses = 5
    var wordLength = 5
    var gameDuration: TimeInterval = 120
    
    private let wordManager = WordManager()
    private var audioPlayer: AVAudioPlayer?
    private var gameTimer: Timer?
    private let statisticsManager = StatisticsManager.shared // Global manager kullan
    
    init(difficulty: DifficultyLevel = .medium) {
        self.maxGuesses = difficulty.maxGuesses
        self.wordLength = difficulty.wordLength
        self.gameDuration = TimeInterval(difficulty.time)
        self.timeRemaining = gameDuration
        
        loadSoundSettings() // Ses ayarlarını yükle
        startNewGame()
    }
    
    // MARK: - Ses Ayarları
    private func loadSoundSettings() {
        soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
        // İlk açılışta default olarak true olsun
        if UserDefaults.standard.object(forKey: "SoundEnabled") == nil {
            soundEnabled = true
            saveSoundSettings()
        }
    }
    
    private func saveSoundSettings() {
        UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        saveSoundSettings()
    }
    
    // MARK: - Oyun Mantığı
    func startNewGame() {
        targetWord = wordManager.getRandomWord(length: wordLength)
        currentGuess = ""
        guesses = []
        gameState = .playing
        jokerManager.resetForNewGame()
        
        // Timer'ı başlat
        timeRemaining = gameDuration
        startTimer()
        
        print("Yeni kelime (\(wordLength) harf): \(targetWord)") // Debug için
    }
    
    func makeGuess() {
        guard currentGuess.count == wordLength,
              gameState == .playing else { return }
        
        let guess = currentGuess.uppercased()
        
        // Kelime kontrolü
        guard wordManager.isValidWord(guess, length: wordLength) else {
            showInvalidWordAlert = true
            return
        }
        
        let result = checkGuess(guess)
        guesses.append(result)
        
        if guess == targetWord {
            gameState = .won
            stopTimer()
            playSound(named: "success")
            updateStatisticsForWin()
        } else if guesses.count >= maxGuesses {
            gameState = .lost
            stopTimer()
            playSound(named: "failure")
            updateStatisticsForLoss()
        } else {
            playSound(named: "tap")
        }
        
        currentGuess = ""
    }
    
    private func checkGuess(_ guess: String) -> GuessResult {
        var letters: [LetterState] = []
        let targetArray = Array(targetWord)
        let guessArray = Array(guess)
        var targetCounts: [Character: Int] = [:]
        
        // Hedef kelimedeki harf sayılarını hesapla
        for char in targetArray {
            targetCounts[char, default: 0] += 1
        }
        
        // İlk geçiş: Doğru konumdaki harfleri işaretle
        for i in 0..<wordLength {
            if guessArray[i] == targetArray[i] {
                letters.append(LetterState(letter: guessArray[i], state: .correct))
                targetCounts[guessArray[i]]! -= 1
            } else {
                letters.append(LetterState(letter: guessArray[i], state: .unused))
            }
        }
        
        // İkinci geçiş: Yanlış konumdaki harfleri işaretle
        for i in 0..<wordLength {
            if letters[i].state == .unused {
                let char = guessArray[i]
                if let count = targetCounts[char], count > 0 {
                    letters[i] = LetterState(letter: char, state: .wrongPosition)
                    targetCounts[char]! -= 1
                } else {
                    letters[i] = LetterState(letter: char, state: .wrong)
                }
            }
        }
        
        return GuessResult(word: guess, letters: letters)
    }
    
    // MARK: - İstatistik Yönetimi
    private func updateStatisticsForWin() {
        statisticsManager.updateForWin(guessCount: guesses.count)
    }
    
    private func updateStatisticsForLoss() {
        statisticsManager.updateForLoss()
    }
    
    // MARK: - Yardımcı Fonksiyonlar
    func getLetterForPosition(row: Int, col: Int) -> Character? {
        // Joker ile açılmış harfleri kontrol et
        if row == guesses.count && jokerManager.revealedLetters.contains(col) {
            return Array(targetWord)[col]
        }
        
        if row < guesses.count {
            return guesses[row].letters[col].letter
        } else if row == guesses.count && col < currentGuess.count {
            return Array(currentGuess.uppercased())[col]
        }
        return nil
    }
    
    func getStateForPosition(row: Int, col: Int) -> LetterGuessState {
        // Joker ile açılmış harfleri yeşil göster
        if row == guesses.count && jokerManager.revealedLetters.contains(col) {
            return .correct
        }
        
        if row < guesses.count {
            return guesses[row].letters[col].state
        }
        return .unused
    }
    
    func addLetter(_ letter: String) {
        if currentGuess.count < wordLength && gameState == .playing {
            currentGuess += letter
            playSound(named: "click")
        }
    }
    
    func deleteLetter() {
        if !currentGuess.isEmpty {
            currentGuess.removeLast()
            playSound(named: "delete")
        }
    }
    
    // MARK: - Timer Yönetimi
    private func startTimer() {
        stopTimer() // Önceki timer'ı durdur
        isTimerActive = true
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if self.timeRemaining > 0 && self.gameState == .playing {
                    self.timeRemaining -= 1
                    
                    // Son 10 saniyede uyarı sesi
                    if self.timeRemaining <= 10 && self.timeRemaining > 0 {
                        self.playSound(named: "tick")
                    }
                } else if self.timeRemaining <= 0 {
                    // Süre doldu
                    self.timeUp()
                }
            }
        }
    }
    
    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
        isTimerActive = false
    }
    
    private func timeUp() {
        gameState = .lost
        stopTimer()
        playSound(named: "failure")
        updateStatisticsForLoss()
    }
    
    // Süre ekleme jokeri için
    func addExtraTime(_ seconds: TimeInterval = 30) {
        timeRemaining += seconds
        playSound(named: "success")
    }
    
    // MARK: - Ses Efektleri (Ayar kontrollü)
    private func playSound(named soundName: String) {
        // Ses kapalıysa çalma
        guard soundEnabled else { return }
        
        // System ses efektlerini kullan
        switch soundName {
        case "click":
            AudioServicesPlaySystemSound(1104) // Keyboard click
        case "delete":
            AudioServicesPlaySystemSound(1155) // Delete key
        case "tap":
            AudioServicesPlaySystemSound(1123) // General tap
        case "success":
            AudioServicesPlaySystemSound(1021) // Success chime
        case "failure":
            AudioServicesPlaySystemSound(1053) // Failure sound
        case "tick":
            AudioServicesPlaySystemSound(1103) // Timer tick
        default:
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    deinit {
        stopTimer()
    }
}
