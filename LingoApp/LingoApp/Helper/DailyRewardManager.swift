//
//  DailyRewardManager.swift
//  LingoApp
//
//  Created by Zeynep Toy on 21.08.2025.
//

import Foundation

struct DailyRewardManager {
    private let lastClaimKey = "LastDailyRewardDate"
    private let streakKey = "DailyStreak"
    
    struct DailyReward {
        let jokerType: JokerType?
        let count: Int
        let isFirstDay: Bool
    }
    
    func claimIfNeeded(jokerManager: JokerManager) -> DailyReward? {
        let today = Calendar.current.startOfDay(for: Date())
        let defaults = UserDefaults.standard
        
        if let lastDate = defaults.object(forKey: lastClaimKey) as? Date,
           Calendar.current.isDate(today, inSameDayAs: lastDate) {
            return nil
        }
        
        if defaults.object(forKey: lastClaimKey) == nil {
            defaults.set(today, forKey: lastClaimKey)
            defaults.set(1, forKey: streakKey)
            
            for type in JokerType.allCases {
                jokerManager.addJoker(type, count: 1)
            }
            
            return DailyReward(jokerType: nil, count: JokerType.allCases.count, isFirstDay: true)
        }
        
        if let lastDate = defaults.object(forKey: lastClaimKey) as? Date,
           Calendar.current.isDate(today.addingTimeInterval(-86400), inSameDayAs: lastDate) {
            
            let oldStreak = defaults.integer(forKey: streakKey)
            let newStreak = min(oldStreak + 1, 5) // max 5
            defaults.set(newStreak, forKey: streakKey)
            defaults.set(today, forKey: lastClaimKey)
            
            let randomType = JokerType.allCases.randomElement() ?? .revealLetter
            jokerManager.addJoker(randomType, count: newStreak)
            return DailyReward(jokerType: randomType, count: newStreak, isFirstDay: false)
        }
        
        defaults.set(today, forKey: lastClaimKey)
        defaults.set(1, forKey: streakKey)
        
        let randomType = JokerType.allCases.randomElement() ?? .revealLetter
        jokerManager.addJoker(randomType, count: 1)
        return DailyReward(jokerType: randomType, count: 1, isFirstDay: false)
    }
}
