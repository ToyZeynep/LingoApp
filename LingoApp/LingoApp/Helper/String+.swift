//
//  String+.swift
//  LingoApp
//
//  Created by Zeynep Toy on 3.08.2025.
//

import Foundation

extension String {
    
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
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
    
    var turkishUppercasedLocale: String {
        return self.uppercased(with: Locale(identifier: "tr_TR"))
    }
    
    var turkishLowercasedLocale: String {
        return self.lowercased(with: Locale(identifier: "tr_TR"))
    }
}

extension String {
    func safeSubstring(at offset: Int) -> Character? {
        guard offset >= 0 && offset < count else { return nil }
        return self[index(startIndex, offsetBy: offset)]
    }
}

