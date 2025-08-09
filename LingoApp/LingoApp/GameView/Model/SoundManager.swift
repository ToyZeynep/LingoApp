//
//  SoundManager.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import AVFoundation
import UIKit

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var systemSoundIDs: [String: SystemSoundID] = [:]
    
    // Alternatif ses ID'leri - En güzel olanlar
    private let soundMap: [String: SystemSoundID] = [
        // Tuş sesleri
        "click": 1104,      // Yumuşak tık
        "delete": 1156,     // Modern silme
        "tap": 1519,        // Tweet sent - güzel feedback
        
        // Oyun sesleri  
        "success": 1407,    // Bloom - zarif başarı sesi
        "failure": 1521,    // Disappointment - sert olmayan
        "invalid": 1114,    // Low warning
        
        // Özel sesler
        "joker": 1115,      // Glass/Crystal
        "reveal": 1520,     // Anticipate
        "reward": 1336,     // Achievement
        "tick": 1074,       // Subtle tick
        "countdown": 1122   // Alert tick
    ]
    
    // Alternatif başarı sesleri (test edebilirsiniz)
    private let successSounds: [SystemSoundID] = [
        1407, // Bloom - en güzeli
        1394, // Sparkle
        1115, // Glass
        1322, // Whoosh
        1025, // Original fanfare
        1111, // Chime
        1328, // Uplift
        1330  // Minuet
    ]
    
    // Alternatif başarısızlık sesleri
    private let failureSounds: [SystemSoundID] = [
        1521, // Disappointment - yumuşak
        1073, // Tink
        1113, // Tock  
        1053, // Original error
        1112, // TaDa (ironik)
        1072, // Pop
        1070, // Tiptoes
        1071  // Typewriters
    ]
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup hatası: \(error)")
        }
    }
    
    // Sistem sesi çalma
    func playSound(named soundName: String, useRandom: Bool = false) {
        guard UserDefaults.standard.bool(forKey: "SoundEnabled") else { return }
        
        var soundID: SystemSoundID
        
        // Özel durumlar için rastgele ses seçimi
        if useRandom {
            switch soundName {
            case "success":
                soundID = successSounds.randomElement() ?? 1407
            case "failure":
                soundID = failureSounds.randomElement() ?? 1521
            default:
                soundID = soundMap[soundName] ?? 1104
            }
        } else {
            soundID = soundMap[soundName] ?? 1104
        }
        
        AudioServicesPlaySystemSound(soundID)
        
        // Haptic feedback
        addHapticFeedback(for: soundName)
    }
    
    // Haptic feedback ekleme
    private func addHapticFeedback(for soundName: String) {
        switch soundName {
        case "success":
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            
        case "failure", "invalid":
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.error)
            
        case "joker", "reveal":
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            
        case "reward":
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            notificationFeedback.notificationOccurred(.success)
            
        case "click", "tap":
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
            
        default:
            break
        }
    }
    
    // Özel ses dosyası çalma (mp3, wav vb.)
    func playCustomSound(fileName: String, fileExtension: String = "mp3") {
        guard UserDefaults.standard.bool(forKey: "SoundEnabled") else { return }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Ses dosyası bulunamadı: \(fileName).\(fileExtension)")
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.volume = 0.5 // Ses seviyesi
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            // Player'ı sakla (ARC tarafından silinmesin)
            audioPlayers[fileName] = audioPlayer
        } catch {
            print("Ses çalma hatası: \(error)")
        }
    }
    
    // Ses önizleme (ayarlar için)
    func previewSound(_ soundName: String) {
        playSound(named: soundName, useRandom: true)
    }
    
    // Tüm başarı seslerini test etme
    func testAllSuccessSounds() {
        for (index, soundID) in successSounds.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
                print("Test ediliyor - Success Sound ID: \(soundID)")
                AudioServicesPlaySystemSound(soundID)
            }
        }
    }
    
    // Tüm başarısızlık seslerini test etme
    func testAllFailureSounds() {
        for (index, soundID) in failureSounds.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
                print("Test ediliyor - Failure Sound ID: \(soundID)")
                AudioServicesPlaySystemSound(soundID)
            }
        }
    }
}

// MARK: - GameModel Extension
extension GameModel {
    func playSoundNew(named soundName: String) {
        guard soundEnabled else { return }
        SoundManager.shared.playSound(named: soundName)
    }
}

// MARK: - Ses Tercihleri
struct SoundPreferences {
    static var successSoundID: SystemSoundID {
        get { SystemSoundID(UserDefaults.standard.integer(forKey: "SuccessSoundID")) }
        set { UserDefaults.standard.set(Int(newValue), forKey: "SuccessSoundID") }
    }
    
    static var failureSoundID: SystemSoundID {
        get { SystemSoundID(UserDefaults.standard.integer(forKey: "FailureSoundID")) }
        set { UserDefaults.standard.set(Int(newValue), forKey: "FailureSoundID") }
    }
}
