//
//  TutorialPageView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Image(systemName: page.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.cyan)
                    
                    Text(page.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                switch page.content {
                case .basicRules:
                    BasicRulesView()
                case .letterColors:
                    LetterColorsView()
                case .jokers:
                    JokersExplanationView()
                case .difficultyLevels:
                    DifficultyLevelsView()
                case .tips:
                    TipsView()
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 25)
        }
    }
}
