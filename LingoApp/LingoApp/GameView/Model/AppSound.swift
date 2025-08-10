//
//  AppSound.swift
//  LingoApp
//
//  Created by Zeynep Toy on 10.08.2025.
//


import AudioToolbox
import UIKit

enum AppSound {
    case start, click, delete, tap, success, failure, invalid, tick, reward

    var id: SystemSoundID {
        switch self {
        case .start:   return 1013
        case .click:   return 1104
        case .delete:  return 1156
        case .tap:     return 1004
        case .success: return 1025
        case .failure: return 1029
        case .invalid: return 1052
        case .tick:    return 1130
        case .reward:  return 1336
        }
    }
}

final class SoundEngine {
    static let shared = SoundEngine()
    private init() {}

    var enabled: Bool {
        get { UserDefaults.standard.object(forKey: "SoundEnabled") == nil ? true : UserDefaults.standard.bool(forKey: "SoundEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "SoundEnabled") }
    }

    private var lastPlayDates: [SystemSoundID: TimeInterval] = [:]
    private let minInterval: TimeInterval = 0.03

    func play(_ sound: AppSound, haptic: (() -> Void)? = nil) {
        guard enabled else { return }

        let now = CACurrentMediaTime()
        let id = sound.id
        if let last = lastPlayDates[id], now - last < minInterval { return }
        lastPlayDates[id] = now

        AudioServicesPlaySystemSound(id)
        haptic?()
    }
}
