//
//  DifficultySelectionView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

// MARK: - Zorluk Seçim Ekranı
struct DifficultySelectionView: View {
    @Binding var selectedDifficulty: DifficultyLevel?
    @State private var animateCards = false
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.3),
                    Color(red: 0.05, green: 0.08, blue: 0.2),
                    Color.black.opacity(0.9)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(Color.cyan.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...40))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 10)
            }
            
            VStack(spacing: 40) {
                // Özgün başlık
                VStack(spacing: 15) {
                    Text("🎯")
                        .font(.system(size: 50))
                        .scaleEffect(animateCards ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateCards)
                    
                    Text("ZORLUK SEVİYESİ")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Seviyeni seç ve meydan okumanı başlat!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)
                
                VStack(spacing: 25) {
                    ForEach(Array(DifficultyLevel.allCases.enumerated()), id: \.element) { index, difficulty in
                        DifficultyCardVertical(
                            difficulty: difficulty,
                            onSelect: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        )
                        .offset(x: animateCards ? 0 : (index % 2 == 0 ? -300 : 300))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double(index) * 0.2), value: animateCards)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .onAppear {
            animateCards = true
        }
    }
}

// MARK: - Dikey Zorluk Kartı (Özgün Tasarım)
struct DifficultyCardVertical: View {
    let difficulty: DifficultyLevel
    let onSelect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: difficulty.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: difficulty.gradientColors.first?.opacity(0.5) ?? .clear, radius: 10, x: 0, y: 5)
                    
                    Image(systemName: difficulty.icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(difficulty.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(difficulty.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Text("\(difficulty.time/60):\(String(format: "%02d", difficulty.time%60))")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(difficulty.gradientColors.first?.opacity(0.8) ?? .blue.opacity(0.8))
                            .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
                            .shadow(color: difficulty.gradientColors.first?.opacity(0.3) ?? .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(difficulty.gradientColors.first ?? .blue)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .scaleEffect(isHovered ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            )
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isHovered = true }
                .onEnded { _ in isHovered = false }
        )
    }
}

// MARK: - Preview
struct DifficultySelectionView_Previews: PreviewProvider {
    @State static var selectedDifficulty: DifficultyLevel? = nil
    
    static var previews: some View {
        DifficultySelectionView(selectedDifficulty: $selectedDifficulty)
    }
}
