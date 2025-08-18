//
//  BasicRulesView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//


import SwiftUI

struct BasicRulesView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 15) {
                Text("Örnek:".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    ForEach(Array("ELMAS".localized.enumerated()), id: \.offset) { index, letter in
                        Text(String(letter))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.gray.opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                RuleItem(number: "1", text: "Gizli kelimeyi tahmin etmeye çalış".localized)
                RuleItem(number: "2", text: "Her tahmin geçerli bir Türkçe kelime olmalı".localized)
                RuleItem(number: "3", text: "Tahmin hakkın zorluk seviyesine göre değişir".localized)
                RuleItem(number: "4", text: "Süre dolmadan kelimeyi bul!".localized)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
