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
                    // İstatistik Kartları
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Oyun",
                            value: "\(statisticsManager.statistics.gamesPlayed)",
                            subtitle: "Toplam",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Kazanma",
                            value: "\(Int(statisticsManager.statistics.winPercentage))%",
                            subtitle: "Oranı",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Şu Anki",
                            value: "\(statisticsManager.statistics.currentStreak)",
                            subtitle: "Seri",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "En İyi",
                            value: "\(statisticsManager.statistics.maxStreak)",
                            subtitle: "Seri",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Tahmin Dağılımı
                    VStack(alignment: .leading, spacing: 15) {
                        Text("TAHMİN DAĞILIMI")
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
                            Text("Henüz oyun oynamadınız")
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
                    
                    // Paylaş butonu
                    if statisticsManager.statistics.gamesPlayed > 0 {
                        Button("STATİSTİKLERİ PAYLAŞ") {
                            shareStatistics()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("İstatistikler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        isPresented = false
                    }
                    .foregroundColor(.cyan)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
        }
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

// MARK: - İstatistik Kartı
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Tahmin Dağılım Satırı
struct GuessDistributionRow: View {
    let guessNumber: Int
    let count: Int
    let maxCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(guessNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 25)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(height: 30)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: barWidth, height: 30)
                
                HStack {
                    Spacer()
                    Text("\(count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(count > 0 ? .white : .white.opacity(0.7))
                        .padding(.trailing, 8)
                }
                .frame(height: 30)
            }
            .cornerRadius(6)
        }
    }
    
    private var barWidth: CGFloat {
        guard maxCount > 0 else { return 0 }
        let maxWidth: CGFloat = 200 // Max bar genişliği
        let percentage = Double(count) / Double(maxCount)
        return max(CGFloat(percentage) * maxWidth, count > 0 ? 40 : 0)
    }
}

// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        StatisticsView(statisticsManager: StatisticsManager.shared, isPresented: $isPresented)
    }
}
