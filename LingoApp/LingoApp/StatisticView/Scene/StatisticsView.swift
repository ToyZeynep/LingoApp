//
//  StatisticsView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

struct StatisticsView: View {
    @ObservedObject var statisticsManager: StatisticsManager
    @Binding var isPresented: Bool
    
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
                
                VStack(spacing: 30) {
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Oyun".localized,
                            value: "\(statisticsManager.statistics.gamesPlayed)",
                            subtitle: "Toplam".localized,
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Kazanma".localized,
                            value: "\(Int(statisticsManager.statistics.winPercentage))%",
                            subtitle: "Oranı".localized,
                            color: .green
                        )
                        
                        StatCard(
                            title: "Şu Anki".localized,
                            value: "\(statisticsManager.statistics.currentStreak)",
                            subtitle: "Seri".localized,
                            color: .orange
                        )
                        
                        StatCard(
                            title: "En İyi".localized,
                            value: "\(statisticsManager.statistics.maxStreak)",
                            subtitle: "Seri".localized,
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
   
                    VStack(alignment: .leading, spacing: 15) {
                        Text("TAHMİN DAĞILIMI".localized)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if statisticsManager.statistics.gamesPlayed > 0 {
                            ForEach(1...6, id: \.self) { guessNumber in
                                GuessDistributionRow(
                                    guessNumber: guessNumber,
                                    count: statisticsManager.statistics.guessDistribution[guessNumber] ?? 0,
                                    maxCount: statisticsManager.statistics.guessDistribution.values.max() ?? 1
                                )
                            }
                        } else {
                            Text("Henüz oyun oynamadınız".localized)
                                .foregroundColor(.white.opacity(0.7))
                                .italic()
                                .padding()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("İstatistikler".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat".localized) {
                        isPresented = false
                    }
                    .foregroundColor(.cyan)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func shareStatistics() {
        let text = statisticsManager.getShareText()
        
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(av, animated: true)
        }
    }
}

// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        StatisticsView(statisticsManager: StatisticsManager.shared, isPresented: $isPresented)
    }
}
