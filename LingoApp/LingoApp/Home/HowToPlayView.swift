//
//  HowToPlayView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.3),
                        Color(red: 0.2, green: 0.1, blue: 0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<tutorialPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? .cyan : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Tutorial content
                    TabView(selection: $currentPage) {
                        ForEach(0..<tutorialPages.count, id: \.self) { index in
                            TutorialPageView(page: tutorialPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // Navigation buttons
                    HStack {
                        if currentPage > 0 {
                            Button("Geri") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .foregroundColor(.cyan)
                            .font(.system(size: 16, weight: .medium))
                        }
                        
                        Spacer()
                        
                        if currentPage < tutorialPages.count - 1 {
                            Button("İleri") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .foregroundColor(.cyan)
                            .font(.system(size: 16, weight: .medium))
                        } else {
                            Button("Başla!") {
                                dismiss()
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Nasıl Oynanır")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Tutorial Page Model
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

// MARK: - Tutorial Page View
struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Icon and title
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
                
                // Description
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // Content based on page type
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

// MARK: - Basic Rules View
struct BasicRulesView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Example word boxes
            VStack(spacing: 15) {
                Text("Örnek:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Example guess
                HStack(spacing: 8) {
                    ForEach(Array("ELMAS".enumerated()), id: \.offset) { index, letter in
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
            
            // Rules list
            VStack(alignment: .leading, spacing: 12) {
                RuleItem(number: "1", text: "Gizli kelimeyi tahmin etmeye çalış")
                RuleItem(number: "2", text: "Her tahmin geçerli bir Türkçe kelime olmalı")
                RuleItem(number: "3", text: "6 tahmin hakkın var")
                RuleItem(number: "4", text: "Süre dolmadan kelimeyi bul!")
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

// MARK: - Letter Colors View
struct LetterColorsView: View {
    var body: some View {
        VStack(spacing: 20) {
            ColorExampleRow(
                letter: "E",
                color: .green,
                title: "Doğru Harf & Doğru Yer",
                description: "Harf kelimede var ve doğru yerde"
            )
            
            ColorExampleRow(
                letter: "L",
                color: .yellow,
                title: "Doğru Harf & Yanlış Yer",
                description: "Harf kelimede var ama yanlış yerde"
            )
            
            ColorExampleRow(
                letter: "X",
                color: .gray,
                title: "Yanlış Harf",
                description: "Harf kelimede hiç yok"
            )
        }
    }
}

// MARK: - Color Example Row
struct ColorExampleRow: View {
    let letter: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            // Letter box
            Text(letter)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
                )
            
            // Explanation
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Jokers Explanation View
struct JokersExplanationView: View {
    var body: some View {
        VStack(spacing: 15) {
            ForEach(JokerType.allCases, id: \.self) { jokerType in
                JokerExplanationRow(jokerType: jokerType)
            }
        }
    }
}

// MARK: - Joker Explanation Row
struct JokerExplanationRow: View {
    let jokerType: JokerType
    
    var body: some View {
        HStack(spacing: 15) {
            // Joker icon
            Image(systemName: jokerType.icon)
                .font(.title2)
                .foregroundColor(jokerType.brightColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(jokerType.brightColor.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(jokerType.brightColor.opacity(0.5), lineWidth: 1)
                        )
                )
            
            // Explanation
            VStack(alignment: .leading, spacing: 4) {
                Text(jokerType.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(jokerType.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Difficulty Levels View
struct DifficultyLevelsView: View {
    var body: some View {
        VStack(spacing: 15) {
            DifficultyRow(level: .easy, description: "4 harf • 6 tahmin • 3 dakika")
            DifficultyRow(level: .medium, description: "5 harf • 5 tahmin • 2.5 dakika")
            DifficultyRow(level: .hard, description: "6 harf • 4 tahmin • 2 dakika")
        }
    }
}

// MARK: - Difficulty Row
struct DifficultyRow: View {
    let level: DifficultyLevel
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            // Difficulty indicator
            Text(level.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(level.color.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(level.color.opacity(0.5), lineWidth: 1)
                        )
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(level.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(level.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Tips View
struct TipsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TipItem(icon: "lightbulb.fill", text: "Yaygın harflerle başla (A, E, İ, R, L)")
            TipItem(icon: "target", text: "Sarı harflerin yerini değiştirmeyi dene")
            TipItem(icon: "clock.fill", text: "Süreyi takip et, gerekirse joker kullan")
            TipItem(icon: "star.fill", text: "İstatistiklerini kontrol ederek gelişimini izle")
        }
    }
}

// MARK: - Helper Views
struct RuleItem: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.cyan)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(.cyan.opacity(0.2))
                )
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

struct TipItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.yellow)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Tutorial Pages Data
private let tutorialPages = [
    TutorialPage(
        title: "Lingo'ya Hoş Geldin!",
        description: "Gizli kelimeyi tahmin etmeye hazır mısın? Temel kuralları öğrenelim.",
        icon: "gamecontroller.fill",
        content: .basicRules
    ),
    TutorialPage(
        title: "Renk Kodları",
        description: "Her harf rengi sana ipucu verir. Renkleri doğru yorumla!",
        icon: "paintpalette.fill",
        content: .letterColors
    ),
    TutorialPage(
        title: "Jokerler",
        description: "Zorlandığında jokerler sana yardım edecek. Akıllıca kullan!",
        icon: "star.fill",
        content: .jokers
    ),
    TutorialPage(
        title: "Zorluk Seviyeleri",
        description: "Kendi seviyene uygun zorluğu seç ve meydan okumaya başla!",
        icon: "target",
        content: .difficultyLevels
    ),
    TutorialPage(
        title: "İpuçları",
        description: "Bu taktiklerle daha başarılı olabilirsin!",
        icon: "lightbulb.fill",
        content: .tips
    )
]

// MARK: - Preview
struct HowToPlayView_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlayView()
    }
}