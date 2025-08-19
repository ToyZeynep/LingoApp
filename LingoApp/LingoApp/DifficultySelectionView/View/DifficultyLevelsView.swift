//
//  DifficultyLevelsView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct DifficultyLevelsView: View {
    var body: some View {
        VStack(spacing: 15) {
            DifficultyRow(level: .easy, description: "4 harf • 6 tahmin • 2.5 dakika".localized)
            DifficultyRow(level: .medium, description: "5 harf • 6 tahmin • 2 dakika".localized)
            DifficultyRow(level: .hard, description: "6 harf • 6 tahmin • 2 dakika".localized)
        }
    }
}
