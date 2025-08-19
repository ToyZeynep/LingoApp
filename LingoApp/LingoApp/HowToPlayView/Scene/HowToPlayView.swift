//
//  HowToPlayView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

struct HowToPlayView: View {
    var onDismiss: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    
    private var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: "HasSeenTutorial")
    }
    
    private func dismissView() {
        if let onDismiss = onDismiss {
            onDismiss()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                    TabView(selection: $currentPage) {
                        ForEach(0..<tutorialPages.count, id: \.self) { index in
                            TutorialPageView(page: tutorialPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 8) {
                            ForEach(0..<tutorialPages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? .cyan : .white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                            }
                        }
                        
                        HStack {
                            if currentPage > 0 {
                                Button("Geri".localized) {
                                    withAnimation {
                                        currentPage -= 1
                                    }
                                }
                                .foregroundColor(.cyan)
                                .font(.system(size: 16, weight: .medium))
                            }
                            
                            Spacer()
                            
                            if currentPage < tutorialPages.count - 1 {
                                Button("İleri".localized) {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                }
                                .foregroundColor(.cyan)
                                .font(.system(size: 16, weight: .medium))
                            } else {
                                Button("Başla!".localized) {
                                    dismissView()
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
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Nasıl Oynanır".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    dismissView()
                }) {
                    Text(isFirstLaunch ? "Atla".localized : "Kapat".localized)
                        .foregroundColor(.cyan)
                        .font(.system(size: 16, weight: .semibold))
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private let tutorialPages = [
    TutorialPage(
        title: "Lingo'ya Hoş Geldin!".localized,
        description: "Gizli kelimeyi tahmin etmeye hazır mısın? Temel kuralları öğrenelim.".localized,
        icon: "gamecontroller.fill",
        content: .basicRules
    ),
    TutorialPage(
        title: "Renk Kodları".localized,
        description: "Her harf rengi sana ipucu verir. Renkleri doğru yorumla!".localized,
        icon: "paintpalette.fill",
        content: .letterColors
    ),
    TutorialPage(
        title: "Jokerler".localized,
        description: "Zorlandığında jokerler sana yardım edecek. Akıllıca kullan!".localized,
        icon: "star.fill",
        content: .jokers
    ),
    TutorialPage(
        title: "Zorluk Seviyeleri".localized,
        description: "Kendi seviyene uygun zorluğu seç ve meydan okumaya başla!".localized,
        icon: "target",
        content: .difficultyLevels
    ),
    TutorialPage(
        title: "İpuçları".localized,
        description: "Bu taktiklerle daha başarılı olabilirsin!".localized,
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
