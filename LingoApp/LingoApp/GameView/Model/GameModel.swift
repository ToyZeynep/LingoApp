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
    @Published var soundEnabled = true
    @Published var isLoadingWord = false
    @Published var revealedPositions: Set<Int> = []
    
    var maxGuesses = 5
    var wordLength = 5
    var gameDuration: TimeInterval = 120
    
    private let wordUploader = WordUploader()
    
    private var audioPlayer: AVAudioPlayer?
    private var gameTimer: Timer?
    private let statisticsManager = StatisticsManager.shared
    private var difficulty: DifficultyLevel
    
    init(difficulty: DifficultyLevel = .medium) {
        self.difficulty = difficulty
        self.maxGuesses = difficulty.maxGuesses
        self.wordLength = difficulty.wordLength
        self.gameDuration = TimeInterval(difficulty.time)
        self.timeRemaining = gameDuration
        
        loadSoundSettings()
        startNewGame()
    }
    
    // MARK: - Ses Ayarları
    private func loadSoundSettings() {
        soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
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
    
    // MARK: - Oyun Mantığı (Firebase ile)
    func startNewGame() {
        isLoadingWord = true
        gameState = .playing
        currentGuess = ""
        guesses = []
        jokerManager.resetForNewGame()
        revealedPositions.removeAll()
        timeRemaining = gameDuration
        
        wordUploader.fetchRandomWord(length: wordLength) { [weak self] word in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let word = word {
                    self.targetWord = word.turkishUppercased
                    self.isLoadingWord = false
                    self.startTimer()
                } else {
                    self.targetWord = self.getFallbackWord()
                    self.isLoadingWord = false
                    self.startTimer()
                }
            }
        }
    }
    
    private func getFallbackWord() -> String {
        let fallbackWords: [Int: [String]] = [
            4: ["KEDI", "MASA", "ELMA", "DAMA", "YAZ"],
            5: ["ELMAS", "KÖPEK", "BAHÇE", "ASLAN", "DÜNYA"],
            6: ["DOKTOR", "OKUL", "BİLGİ", "ARKADAŞ", "GÜNEŞ"]
        ]
        
        return fallbackWords[wordLength]?.randomElement() ?? "ERROR"
    }
    
    func makeGuess() {
        let completeGuess = buildCompleteGuess()
        
        guard completeGuess.count == wordLength,
              gameState == .playing,
              !isLoadingWord else {
            return
        }
        
        if completeGuess == targetWord {
            DispatchQueue.main.async {
                self.gameState = .won
                self.stopTimer()
                self.playSound(named: "success")
                self.updateStatisticsForWin()
                self.currentGuess = ""
            }
            return
        }
        
        validateWordAndProcess(completeGuess)
    }
    
    private func buildCompleteGuess() -> String {
        var completeGuess = ""
        var currentGuessIndex = 0
        let currentGuessArray = Array(currentGuess.turkishUppercased)
        
        for position in 0..<wordLength {
            if revealedPositions.contains(position) {
                let targetIndex = targetWord.index(targetWord.startIndex, offsetBy: position)
                completeGuess += String(targetWord[targetIndex])
            } else {
                if currentGuessIndex < currentGuessArray.count {
                    completeGuess += String(currentGuessArray[currentGuessIndex])
                    currentGuessIndex += 1
                } else {
                    return currentGuess.turkishUppercased
                }
            }
        }
        
        return completeGuess
    }
    
    private func validateWordAndProcess(_ guess: String) {
        
        wordUploader.isValidWord(guess) { [weak self] (isValid: Bool) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if isValid {
                    self.processNormalGuess(guess)
                } else {
                    self.showInvalidWordAlert = true
                    self.playSound(named: "failure")
                }
            }
        }
    }
    
    private func processNormalGuess(_ guess: String) {
        let result = checkGuess(guess)
        guesses.append(result)
        updateRevealedPositionsFromGuess(guess)
        
        if guesses.count >= maxGuesses {
            gameState = .lost
            stopTimer()
            playSound(named: "failure")
            updateStatisticsForLoss()
        } else {
            playSound(named: "tap")
        }
        
        currentGuess = ""
    }
    
    private func processValidGuess(_ guess: String) {
        let result = checkGuess(guess)
        guesses.append(result)
        
        updateRevealedPositionsFromGuess(guess)
        
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
    
    private func updateRevealedPositionsFromGuess(_ guess: String) {
        for (index, char) in guess.enumerated() {
            if index < targetWord.count &&
               targetWord[targetWord.index(targetWord.startIndex, offsetBy: index)] == char {
                revealedPositions.insert(index)
            }
        }
    }
    
    func useJoker() {
        let unrevealedPositions = Set(0..<wordLength).subtracting(revealedPositions)
        
        if let randomPosition = unrevealedPositions.randomElement() {
            revealedPositions.insert(randomPosition)
            
            removeLetterAtRevealedPosition(randomPosition)
            
            playSound(named: "success")
            
            jokerManager.revealedLetters.insert(randomPosition)
        }
    }
    
    private func removeLetterAtRevealedPosition(_ revealedPosition: Int) {
        let nonRevealedPositions = (0..<wordLength).filter { !revealedPositions.contains($0) || $0 == revealedPosition }
        
        if let indexToRemove = nonRevealedPositions.firstIndex(of: revealedPosition) {
            var currentGuessArray = Array(currentGuess)
            
            if indexToRemove < currentGuessArray.count {
                currentGuessArray.remove(at: indexToRemove)
                currentGuess = String(currentGuessArray)
            }
        }
    }
    
    private func checkGuess(_ guess: String) -> GuessResult {
        var letters: [LetterState] = []
        let targetArray = Array(targetWord)
        let guessArray = Array(guess)
        var targetCounts: [Character: Int] = [:]
        
        for char in targetArray {
            targetCounts[char, default: 0] += 1
        }
        
        for i in 0..<wordLength {
            if guessArray[i] == targetArray[i] {
                letters.append(LetterState(letter: guessArray[i], state: .correct))
                targetCounts[guessArray[i]]! -= 1
            } else {
                letters.append(LetterState(letter: guessArray[i], state: .unused))
            }
        }
        
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
    
    func getLetterForPosition(row: Int, col: Int) -> Character? {

        if row < guesses.count {
            return guesses[row].letters[col].letter
        }
        
        if row == guesses.count {
            if revealedPositions.contains(col) {
                let targetIndex = targetWord.index(targetWord.startIndex, offsetBy: col)
                return targetWord[targetIndex]
            }
            
            var currentGuessIndex = 0
            for position in 0..<col {
                if !revealedPositions.contains(position) {
                    currentGuessIndex += 1
                }
            }
            
            let currentGuessArray = Array(currentGuess.turkishUppercased)
            if currentGuessIndex < currentGuessArray.count {
                return currentGuessArray[currentGuessIndex]
            }
        }
        
        return nil
    }
    
    func getStateForPosition(row: Int, col: Int) -> LetterGuessState {
    
        if row < guesses.count {
            return guesses[row].letters[col].state
        }
        
        if row == guesses.count {
            if revealedPositions.contains(col) {
                return .revealed
            }
        }
        
        return .unused
    }
    
    func addLetter(_ letter: String) {
        let remainingLettersNeeded = wordLength - revealedPositions.count
        
        if currentGuess.count < remainingLettersNeeded && gameState == .playing && !isLoadingWord {
            currentGuess += letter
            playSound(named: "click")
        }
    }
    
    func deleteLetter() {
        if !currentGuess.isEmpty && !isLoadingWord {
            currentGuess.removeLast()
            playSound(named: "delete")
        }
    }
    
    // MARK: - Timer Yönetimi
    private func startTimer() {
        stopTimer()
        isTimerActive = true
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if self.timeRemaining > 0 && self.gameState == .playing {
                    self.timeRemaining -= 1
                    
                    if self.timeRemaining <= 10 && self.timeRemaining > 0 {
                        self.playSound(named: "tick")
                    }
                } else if self.timeRemaining <= 0 {
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
    
    func addExtraTime(_ seconds: TimeInterval = 30) {
        timeRemaining += seconds
        playSound(named: "success")
    }
    
    // MARK: - Ses Efektleri
    private func playSound(named soundName: String) {
        guard soundEnabled else { return }
        
        switch soundName {
        case "click":
            AudioServicesPlaySystemSound(1104)
        case "delete":
            AudioServicesPlaySystemSound(1155)
        case "tap":
            AudioServicesPlaySystemSound(1123)
        case "success":
            AudioServicesPlaySystemSound(1021)
        case "failure":
            AudioServicesPlaySystemSound(1053)
        case "tick":
            AudioServicesPlaySystemSound(1103)
        default:
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    deinit {
        stopTimer()
    }
}
