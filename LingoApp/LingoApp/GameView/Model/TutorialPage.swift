//
//  TutorialPage.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//


import Foundation

struct TutorialPage {
    let title: String
    let description: String
    let icon: String
    let content: TutorialContent
}

enum TutorialContent {
    case basicRules
    case letterColors
    case jokers
    case difficultyLevels
    case tips
}
