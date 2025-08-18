//
//  TipsView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct TipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TipItem(icon: "lightbulb.fill", text: "Yaygın harflerle başla (A, E, İ, R, L)".localized)
            TipItem(icon: "target", text: "Sarı harflerin yerini değiştirmeyi dene".localized)
            TipItem(icon: "clock.fill", text: "Süreyi takip et, gerekirse joker kullan".localized)
            TipItem(icon: "star.fill", text: "İstatistiklerini kontrol ederek gelişimini izle".localized)
        }
    }
}
