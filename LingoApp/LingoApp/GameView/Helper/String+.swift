//
//  String+.swift
//  LingoApp
//
//  Created by Zeynep Toy on 3.08.2025.
//

import Foundation

extension String {
    
    /// Türkçe karakterleri doğru şekilde büyük harfe çevirir
    var turkishUppercased: String {
        return self
            .replacingOccurrences(of: "ı", with: "I")
            .replacingOccurrences(of: "i", with: "İ")
            .replacingOccurrences(of: "ş", with: "Ş")
            .replacingOccurrences(of: "ğ", with: "Ğ")
            .replacingOccurrences(of: "ü", with: "Ü")
            .replacingOccurrences(of: "ö", with: "Ö")
            .replacingOccurrences(of: "ç", with: "Ç")
            .uppercased()
    }
    
    /// Türkçe karakterleri doğru şekilde küçük harfe çevirir
    var turkishLowercased: String {
        return self
            .replacingOccurrences(of: "I", with: "ı")
            .replacingOccurrences(of: "İ", with: "i")
            .replacingOccurrences(of: "Ş", with: "ş")
            .replacingOccurrences(of: "Ğ", with: "ğ")
            .replacingOccurrences(of: "Ü", with: "ü")
            .replacingOccurrences(of: "Ö", with: "ö")
            .replacingOccurrences(of: "Ç", with: "ç")
            .lowercased()
    }
    
    /// Türkçe locale ile büyük harf (alternatif yöntem)
    var turkishUppercasedLocale: String {
        return self.uppercased(with: Locale(identifier: "tr_TR"))
    }
    
    /// Türkçe locale ile küçük harf (alternatif yöntem)
    var turkishLowercasedLocale: String {
        return self.lowercased(with: Locale(identifier: "tr_TR"))
    }
}

// MARK: - Test Fonksiyonu
extension String {
    static func testTurkishConversion() {
        let testWords = ["istanbul", "İzmir", "şehir", "ğüzel", "çiçek", "ırmak"]
        
        print("🧪 Türkçe Karakter Test:")
        print("========================")
        
        for word in testWords {
            print("Original: \(word)")
            print("Standard uppercased(): \(word.uppercased())")
            print("Turkish uppercased: \(word.turkishUppercased)")
            print("Turkish locale: \(word.turkishUppercasedLocale)")
            print("---")
        }
    }
}
