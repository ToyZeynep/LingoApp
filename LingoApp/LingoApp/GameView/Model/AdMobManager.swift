//
//  AdMobManager.swift
//  LingoApp
//
//  Updated for Google Mobile Ads SDK v11+
//

import Foundation
import GoogleMobileAds
import UIKit

class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()
    
    @Published var isRewardedAdReady = false
    @Published var isInterstitialAdReady = false
    @Published var isLoading = false
    
    private var rewardedAd: RewardedAd?
    private var interstitialAd: InterstitialAd?
    private var rewardCompletion: ((Bool) -> Void)?
    
    // Test ID'leri - production'da gerçek ID'lerle değiştirin
    private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313" // Test Rewarded
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910" // Test Interstitial
    
    override init() {
        super.init()
        initializeGoogleMobileAds()
    }
    
    private func initializeGoogleMobileAds() {
        // Test cihazları ayarla
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [
            "SIMULATOR", // iOS Simulator
        ]
        
        MobileAds.shared.start { [weak self] status in
            print("✅ Google Mobile Ads SDK initialized.")
            
            // Network bağlantısını kontrol et
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self?.loadRewardedAd()
                self?.loadInterstitialAd()
            }
        }
    }
    
    // MARK: - Rewarded Ad
    func loadRewardedAd() {
        guard !isLoading else { return }
        
        isLoading = true
        isRewardedAdReady = false
        
        let request = Request()
        
        // Yeni API kullanımı
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Rewarded ad failed to load: \(error.localizedDescription)")
                    self?.isRewardedAdReady = false
                    
                    // Network hatası varsa 5 saniye sonra tekrar dene
                    if error.localizedDescription.contains("network") ||
                       error.localizedDescription.contains("connection") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            self?.loadRewardedAd()
                        }
                    }
                    return
                }
                
                guard let ad = ad else {
                    print("Rewarded ad is nil")
                    self?.isRewardedAdReady = false
                    return
                }
                
                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isRewardedAdReady = true
                print("✅ Rewarded ad loaded successfully")
            }
        }
    }
    
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let rewardedAd = rewardedAd else {
            print("Rewarded ad is not ready")
            completion(false)
            return
        }
        
        // En üstteki view controller'ı bul
        guard let rootViewController = findTopViewController() else {
            print("Could not find top view controller")
            completion(false)
            return
        }
        
        // Eğer zaten bir modal sunuyorsa bekle
        if rootViewController.presentedViewController != nil {
            print("View controller is already presenting, waiting...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showRewardedAd(completion: completion)
            }
            return
        }
        
        self.rewardCompletion = completion
        
        rewardedAd.present(from: rootViewController) {
            // Kullanıcı reklamı tamamen izledi ve ödül kazandı
            print("✅ User earned reward")
            DispatchQueue.main.async { [weak self] in
                self?.rewardCompletion?(true)
                self?.rewardCompletion = nil
            }
        }
    }
    
    // MARK: - Interstitial Ad (Bonus)
    func loadInterstitialAd() {
        let request = Request()
        
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Interstitial ad failed to load: \(error.localizedDescription)")
                    self?.isInterstitialAdReady = false
                    
                    // Network hatası varsa 10 saniye sonra tekrar dene
                    if error.localizedDescription.contains("network") ||
                       error.localizedDescription.contains("connection") ||
                       error.localizedDescription.contains("parse") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            self?.loadInterstitialAd()
                        }
                    }
                    return
                }
                
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.isInterstitialAdReady = true
                print("✅ Interstitial ad loaded successfully")
            }
        }
    }
    
    func showInterstitialAd() {
        guard let interstitialAd = interstitialAd else {
            print("Interstitial ad is not ready")
            return
        }
        
        // En üstteki view controller'ı bul
        guard let rootViewController = findTopViewController() else {
            print("Could not find top view controller")
            return
        }
        
        // Eğer zaten bir modal sunuyorsa çıkış yap
        if rootViewController.presentedViewController != nil {
            print("View controller is already presenting, skipping interstitial")
            return
        }
        
        interstitialAd.present(from: rootViewController)
    }
    
    // MARK: - Banner Ad (isteğe bağlı)
    func createBannerView() -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174" // Test Banner
        
        // Root view controller'ı ayarla
        if let rootViewController = findTopViewController() {
            bannerView.rootViewController = rootViewController
        }
        
        let request = Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    // MARK: - Helper Methods
    private func findTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var topViewController = window.rootViewController
        
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdMobManager: FullScreenContentDelegate {
    
    // Reklam gösterildiğinde
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad will present full screen content")
    }
    
    // Reklam kapatıldığında
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad did dismiss full screen content")
        
        DispatchQueue.main.async { [weak self] in
            if ad is RewardedAd {
                // Rewarded ad kapatıldı - yeni reklam yükle
                self?.rewardedAd = nil
                self?.isRewardedAdReady = false
                
                // Completion çağrılmamışsa (kullanıcı reklamı izlemeden kapattı)
                if let completion = self?.rewardCompletion {
                    completion(false)
                    self?.rewardCompletion = nil
                }
                
                // Biraz bekle sonra yeni reklam yükle
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.loadRewardedAd()
                }
            } else if ad is InterstitialAd {
                // Interstitial ad kapatıldı - yeni reklam yükle
                self?.interstitialAd = nil
                self?.isInterstitialAdReady = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.loadInterstitialAd()
                }
            }
        }
    }
    
    // Reklam gösterilirken hata oluşursa
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        
        DispatchQueue.main.async { [weak self] in
            if ad is RewardedAd {
                self?.rewardCompletion?(false)
                self?.rewardCompletion = nil
                self?.loadRewardedAd()
            } else if ad is InterstitialAd {
                self?.loadInterstitialAd()
            }
        }
    }
    
    // Reklam impression kaydedildiğinde
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Ad recorded an impression")
    }
    
    // Reklam tıklandığında
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("Ad recorded a click")
    }
}

// MARK: - GADRewardedAdDelegate
extension AdMobManager {
    
    // Rewarded ad için özel completion handler
    private func handleRewardedAdCompletion(reward: AdReward) {
        print("User earned reward: \(reward.amount) \(reward.type)")
        
        DispatchQueue.main.async { [weak self] in
            self?.rewardCompletion?(true)
            self?.rewardCompletion = nil
        }
    }
}

// MARK: - Convenience Methods
extension AdMobManager {
    
    // Reklam durumunu kontrol et
    var canShowRewardedAd: Bool {
        return isRewardedAdReady && !isLoading
    }
    
    var canShowInterstitialAd: Bool {
        return isInterstitialAdReady
    }
    
    // Network durumunu kontrol et
    var isNetworkAvailable: Bool {
        return true // Şimdilik her zaman true döndür
    }
    
    // Fallback mekanizması - reklam yüklenemezse alternatif
    func showRewardedAdWithFallback(completion: @escaping (Bool) -> Void) {
        if canShowRewardedAd {
            showRewardedAd(completion: completion)
        } else {
            // Reklam hazır değilse, yeniden yüklemeyi dene
            loadRewardedAd()
            
            // 3 saniye bekle ve tekrar kontrol et
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if self.canShowRewardedAd {
                    self.showRewardedAd(completion: completion)
                } else {
                    // Hala yüklenmediyse false döndür
                    completion(false)
                }
            }
        }
    }
    
    // Tüm reklamları yeniden yükle
    func reloadAllAds() {
        loadRewardedAd()
        loadInterstitialAd()
    }
    
    // Debug bilgileri
    func getAdStatus() -> String {
        return """
        Rewarded Ad: \(isRewardedAdReady ? "Ready" : "Not Ready")
        Interstitial Ad: \(isInterstitialAdReady ? "Ready" : "Not Ready")
        Loading: \(isLoading)
        """
    }
}
