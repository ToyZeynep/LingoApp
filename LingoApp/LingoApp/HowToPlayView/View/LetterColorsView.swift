//
//  LetterColorsView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct LetterColorsView: View {
    var body: some View {
        VStack(spacing: 20) {
            ColorExampleRow(
                letter: "E",
                color: .cyan,
                title: "Doğru Harf & Doğru Yer".localized,
                description: "Harf kelimede var ve doğru yerde".localized
            )
            
            ColorExampleRow(
                letter: "L",
                color: .orange,
                title: "Doğru Harf & Yanlış Yer".localized,
                description: "Harf kelimede var ama yanlış yerde".localized
            )
            
            ColorExampleRow(
                letter: "X",
                color: .gray,
                title: "Yanlış Harf".localized,
                description: "Harf kelimede hiç yok".localized
            )
        }
    }
}
