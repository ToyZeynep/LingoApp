//
//  StatisticsManager.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import Foundation

// MARK: - Singleton Statistics Manager
class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    
    @Published var statistics = GameStatistics()
    
    private init() {
        loadStatistics()
    }
    
    // MARK: - İstatistik Güncellemeleri
    func updateForWin(guessCount: Int) {
        statistics.gamesPlayed += 1
        statistics.gamesWon += 1
        statistics.currentStreak += 1
        statistics.maxStreak = max(statistics.maxStreak, statistics.currentStreak)
        statistics.guessDistribution[guessCount, default: 0] += 1
        saveStatistics()
    }
    
    func updateForLoss() {
        statistics.gamesPlayed += 1
        statistics.currentStreak = 0
        saveStatistics()
    }
    
    // MARK: - Kaydetme/Yükleme
    private func saveStatistics() {
        if let encoded = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(encoded, forKey: "GlobalGameStatistics")
        }
    }
    
    private func loadStatistics() {
        if let data = UserDefaults.standard.data(forKey: "GlobalGameStatistics"),
           let decoded = try? JSONDecoder().decode(GameStatistics.self, from: data) {
            statistics = decoded
        }
    }
    
    // MARK: - Yardımcı Fonksiyonlar
    func resetStatistics() {
        statistics = GameStatistics()
        saveStatistics()
    }
    
    func getShareText() -> String {
        return """
        Türkçe Lingo İstatistiklerim:
        🎯 \(statistics.gamesPlayed) oyun oynadım
        🏆 %\(Int(statistics.winPercentage)) kazanma oranı
        🔥 \(statistics.currentStreak) şu anki seri
        ⭐ \(statistics.maxStreak) en iyi seri
        """
    }
}