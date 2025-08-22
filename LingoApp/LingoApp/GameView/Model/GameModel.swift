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
    @Published var currentWordMeaning: String = ""
    @Published var showHintText = false
    @Published var totalCorrectGuesses = UserDefaults.standard.integer(forKey: "TotalCorrectGuesses")
    @Published var showJokerRewardAlert = false
    @Published var rewardedJokerType: JokerType? = nil
    @Published var isTimerPaused: Bool = false
    
    var maxGuesses = Int.max
    var visibleGuesses = 5
    var wordLength = 5
    var gameDuration: TimeInterval = 120
    
    private let wordUploader = WordUploader.shared
    
    private var audioPlayer: AVAudioPlayer?
    private var gameTimer: Timer?
    private let statisticsManager = StatisticsManager.shared
    private var difficulty: DifficultyLevel
    
    init(difficulty: DifficultyLevel = .medium) {
        self.difficulty = difficulty
        self.visibleGuesses = 5
        self.wordLength = difficulty.wordLength
        self.gameDuration = TimeInterval(difficulty.time)
        self.timeRemaining = gameDuration
        
        loadSoundSettings()
        startNewGame()
    }
    
    // MARK: - Language Detection
    
    /// Kullanıcının seçtiği dili döndürür
    private var selectedLanguage: String {
        return UserDefaults.standard.string(forKey: "selectedLanguage") ?? "tr"
    }
    
    /// Seçili dile göre uygun dil kodunu döndürür
    private var isEnglishMode: Bool {
        return selectedLanguage == "en"
    }
    
    var isEnglishKeyboard: Bool { isEnglishMode }
    
    var displayedGuessCount: Int {
        return visibleGuesses
    }
    
    var scrollOffset: Int {
        return max(0, guesses.count - visibleGuesses + 1)
    }
    
    // MARK: - Ses Ayarları
    private func loadSoundSettings() {
        soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
        if UserDefaults.standard.object(forKey: "SoundEnabled") == nil {
            soundEnabled = true
            saveSoundSettings()
        }
    }
    
    func pauseTimer() {
            isTimerPaused = true
            print("⏸️ Timer paused")
        }
        
        func resumeTimer() {
            isTimerPaused = false
            print("▶️ Timer resumed")
        }
    
    private func saveSoundSettings() {
        UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
    }
    
    func toggleSound() {
        soundEnabled.toggle()
        saveSoundSettings()
    }
    
    func startNewGame() {
        isLoadingWord = true
        gameState = .playing
        currentGuess = ""
        guesses = []
        jokerManager.resetForNewGame()
        revealedPositions.removeAll()
        timeRemaining = gameDuration
        showHintText = false
        currentWordMeaning = ""
        
        playSound(named: "gameStart")
        
        // Dil seçimine göre kelime çek
        if isEnglishMode {
            fetchEnglishWord()
        } else {
            fetchTurkishWord()
        }
    }
    
    // MARK: - Language-Aware Word Fetching
    
    private func fetchTurkishWord() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let result = self.wordUploader.fetchRandomTurkishWord(length: self.wordLength)

            DispatchQueue.main.async {
                if let wd = result {
                    self.targetWord = wd.word.turkishUppercased
                    self.currentWordMeaning = wd.mean
                    print("🇹🇷 Türkçe kelime: \(self.targetWord) - Anlam: \(self.currentWordMeaning)")
                } else {
                    let fb = self.getFallbackTurkishWordWithMeaning()
                    self.targetWord = fb.word
                    self.currentWordMeaning = fb.meaning
                    print("⚠️ Türkçe fallback kelime: \(self.targetWord)")
                }
                self.isLoadingWord = false
                self.startTimer()
            }
        }
    }

    
    private func fetchEnglishWord() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let result = self.wordUploader.fetchRandomEnglishWord(length: self.wordLength)

            DispatchQueue.main.async {
                if let wd = result {
                    self.targetWord = wd.word.uppercased()
                    self.currentWordMeaning = wd.mean
                    print("🇺🇸 English word: \(self.targetWord) - Meaning: \(self.currentWordMeaning)")
                } else {
                    let fb = self.getFallbackEnglishWordWithMeaning()
                    self.targetWord = fb.word
                    self.currentWordMeaning = fb.meaning
                    print("⚠️ English fallback word: \(self.targetWord)")
                }
                self.isLoadingWord = false
                self.startTimer()
            }
        }
    }

    
    // MARK: - Fallback Words
    
    private func getFallbackTurkishWordWithMeaning() -> (word: String, meaning: String) {
        let fallbackWordsWithMeanings: [Int: [(String, String)]] = [
            4: [
                ("KEDI", "Evde besilen, miyavlayan dört ayaklı hayvan"),
                ("MASA", "Üzerine yemek yenilen, çalışılan düz yüzey"),
                ("ELMA", "Kırmızı veya yeşil renkli, tatlı meyve"),
                ("DAMA", "Tahtada oynanan strateji oyunu"),
                ("YAŞZ", "Sıcak mevsim, tatil zamanı")
            ],
            5: [
                ("ELMAS", "Çok değerli, parlak taş"),
                ("KÖPEK", "Evde besilen, havlayan dört ayaklı hayvan"),
                ("BAHÇE", "Çiçek ve sebze yetiştirilen alan"),
                ("ASLAN", "Ormanlarda yaşayan büyük kedi"),
                ("DÜNYA", "Üzerinde yaşadığımız gezegen")
            ],
            6: [
                ("DOKTOR", "Hastaları tedavi eden kişi"),
                ("OKUL", "Eğitim verilen yer"),
                ("BİLGİ", "Öğrenilen, bilinen şeyler"),
                ("ARKADŞ", "Sevdiğimiz, güvendiğimiz kişi"),
                ("GÜNEŞ", "Gündüz ışık veren yıldız")
            ]
        ]
        
        let wordsForLength = fallbackWordsWithMeanings[wordLength] ?? [("ERROR", "Hata")]
        let selected = wordsForLength.randomElement() ?? ("ERROR", "Hata")
        return selected
    }
    
    private func getFallbackEnglishWordWithMeaning() -> (word: String, meaning: String) {
        let fallbackWordsWithMeanings: [Int: [(String, String)]] = [
            4: [
                ("LOVE", "A strong feeling of affection"),
                ("TIME", "The indefinite continued progress of existence"),
                ("BOOK", "A written work consisting of pages"),
                ("DOOR", "A hinged barrier for entrance"),
                ("WORK", "Activity involving effort or exertion")
            ],
            5: [
                ("HOUSE", "A building for human habitation"),
                ("WATER", "A transparent liquid essential for life"),
                ("LIGHT", "Natural illumination from the sun"),
                ("MUSIC", "Vocal or instrumental sounds combined"),
                ("SMILE", "A pleased, kind, or amused facial expression")
            ],
            6: [
                ("FRIEND", "A person you know well and like"),
                ("FAMILY", "A group of related people"),
                ("SCHOOL", "An institution for learning"),
                ("ANIMAL", "A living organism that feeds on matter"),
                ("NATURE", "The phenomena of the physical world")
            ]
        ]
        
        let wordsForLength = fallbackWordsWithMeanings[wordLength] ?? [("ERROR", "Error")]
        let selected = wordsForLength.randomElement() ?? ("ERROR", "Error")
        return selected
    }
    
    func useHintJoker() {
        showHintText = true
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
                self.checkAndRewardJoker()
                self.currentGuess = ""
            }
            return
        }
        
        validateWordAndProcess(completeGuess)
    }
    
    private func buildCompleteGuess() -> String {
        var completeGuess = ""
        var currentGuessIndex = 0
        let currentGuessArray = isEnglishMode ?
            Array(currentGuess.uppercased()) :
            Array(currentGuess.turkishUppercased)
        
        for position in 0..<wordLength {
            if revealedPositions.contains(position) {
                if let character = targetWord.safeSubstring(at: position) {
                    completeGuess += String(character)
                }
            } else {
                if currentGuessIndex < currentGuessArray.count {
                    completeGuess += String(currentGuessArray[currentGuessIndex])
                    currentGuessIndex += 1
                } else {
                    return isEnglishMode ?
                        currentGuess.uppercased() :
                        currentGuess.turkishUppercased
                }
            }
        }
        
        return completeGuess
    }
    
    private func validateWordAndProcess(_ guess: String) {
        if isEnglishMode {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                let isValid = self.wordUploader.isValidEnglishWord(guess.capitalized)
                DispatchQueue.main.async {
                    self.handleValidationResult(isValid: isValid, guess: guess)
                }
            }
        } else {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                let isValid = self.wordUploader.isValidTurkishWord(guess.turkishLowercased)
                DispatchQueue.main.async {
                    self.handleValidationResult(isValid: isValid, guess: guess)
                }
            }
        }
    }
    
    private func handleValidationResult(isValid: Bool, guess: String) {
        if isValid {
            processNormalGuess(guess)
        } else {
            currentGuess = ""
            showInvalidWordAlert = true
            playSound(named: "invalid")
            
            // Dil bazlı log
            let language = isEnglishMode ? "English" : "Turkish"
            print("❌ Invalid \(language) word: \(guess)")
        }
    }
    
    private func processNormalGuess(_ guess: String) {
        let result = checkGuess(guess)
        guesses.append(result)
        updateRevealedPositionsFromGuess(guess)
        playSound(named: "tap")
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
    
    private func checkAndRewardJoker() {
        totalCorrectGuesses += 1
        UserDefaults.standard.set(totalCorrectGuesses, forKey: "TotalCorrectGuesses")
        
        if totalCorrectGuesses % 10 == 0 && totalCorrectGuesses > 0 {
            let jokerTypes = JokerType.allCases
            let randomJoker = jokerTypes.randomElement() ?? .revealLetter
            
            jokerManager.addJoker(randomJoker, count: 1)
            
            rewardedJokerType = randomJoker
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.playSound(named: "reward")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showJokerRewardAlert = true
            }
            
            checkSpecialMilestoneRewards()
        }
    }

    private func checkSpecialMilestoneRewards() {
        switch totalCorrectGuesses {
        case 50:
            jokerManager.addJoker(.revealLetter, count: 2)
            jokerManager.addJoker(.removeLetter, count: 1)
        case 100:
            jokerManager.addJoker(.revealLetter, count: 3)
            jokerManager.addJoker(.removeLetter, count: 2)
            jokerManager.addJoker(.extraTime, count: 2)
        case 250:
            JokerType.allCases.forEach { type in
                jokerManager.addJoker(type, count: 5)
            }
        default:
            break
        }
    }
    
    func getProgressToNextReward() -> (current: Int, needed: Int) {
        let current = totalCorrectGuesses % 10
        let needed = 10 - current
        return (current, needed)
    }

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
            
            let currentGuessArray = isEnglishMode ?
                Array(currentGuess.uppercased()) :
                Array(currentGuess.turkishUppercased)
            
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
    
    private func startTimer() {
        stopTimer()
        isTimerActive = true
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard !self.isTimerPaused else { return }
                
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
    }
    
    // MARK: - Language Status Methods
    
    /// Mevcut oyun dilini döndürür
    func getCurrentLanguageDisplay() -> String {
        return isEnglishMode ? "🇺🇸 English" : "🇹🇷 Türkçe"
    }
    
    /// Dil değişikliği olduğunda oyunu yeniden başlat
    func onLanguageChanged() {
        print("🌍 Oyun dili değişti: \(getCurrentLanguageDisplay())")
        startNewGame() // Yeni dilde kelime ile oyunu yeniden başlat
    }
    
    private func playSound(named soundName: String) {
        guard SoundEngine.shared.enabled else { return }

        switch soundName {
        case "click":
            SoundEngine.shared.play(.click)
        case "delete":
            SoundEngine.shared.play(.delete)
        case "tap":
            SoundEngine.shared.play(.tap)
        case "success":
            SoundEngine.shared.play(.success) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        case "failure":
            SoundEngine.shared.play(.failure) {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        case "tick":
            SoundEngine.shared.play(.tick)
        case "invalid":
            SoundEngine.shared.play(.invalid) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        case "reward":
            SoundEngine.shared.play(.reward) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        case "gameStart":
            SoundEngine.shared.play(.start) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        default:
            SoundEngine.shared.play(.click)
        }
    }
    
    deinit {
        stopTimer()
    }
}
