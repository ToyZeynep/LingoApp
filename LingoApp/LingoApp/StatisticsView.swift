//
//  StatisticsView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import SwiftUI

struct StatisticsView: View {
    @ObservedObject var game: GameModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // İstatistik Kartları
                HStack(spacing: 20) {
                    StatCard(
                        title: "Oyun",
                        value: "\(game.statistics.gamesPlayed)",
                        subtitle: "Toplam"
                    )
                    
                    StatCard(
                        title: "Kazanma",
                        value: "\(Int(game.statistics.winPercentage))%",
                        subtitle: "Oranı"
                    )
                    
                    StatCard(
                        title: "Şu Anki",
                        value: "\(game.statistics.currentStreak)",
                        subtitle: "Seri"
                    )
                    
                    StatCard(
                        title: "En İyi",
                        value: "\(game.statistics.maxStreak)",
                        subtitle: "Seri"
                    )
                }
                
                // Tahmin Dağılımı
                VStack(alignment: .leading, spacing: 15) {
                    Text("TAHMİN DAĞILIMI")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(1...6, id: \.self) { guessNumber in
                        GuessDistributionRow(
                            guessNumber: guessNumber,
                            count: game.statistics.guessDistribution[guessNumber] ?? 0,
                            maxCount: game.statistics.guessDistribution.values.max() ?? 1
                        )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                // Paylaş butonu
                Button("STATİSTİKLERİ PAYLAŞ") {
                    shareStatistics()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("İstatistikler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func shareStatistics() {
        let text = """
        Türkçe Lingo İstatistiklerim:
        🎯 \(game.statistics.gamesPlayed) oyun oynadım
        🏆 %\(Int(game.statistics.winPercentage)) kazanma oranı
        🔥 \(game.statistics.currentStreak) şu anki seri
        ⭐ \(game.statistics.maxStreak) en iyi seri
        """
        
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
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 70, minHeight: 80)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Tahmin Dağılım Satırı
struct GuessDistributionRow: View {
    let guessNumber: Int
    let count: Int
    let maxCount: Int
    
    var body: some View {
        HStack {
            Text("\(guessNumber)")
                .font(.system(size: 14, weight: .medium))
                .frame(width: 20)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 25)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: barWidth, height: 25)
                
                HStack {
                    Spacer()
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(count > 0 ? .white : .primary)
                        .padding(.trailing, 8)
                }
                .frame(height: 25)
            }
            .cornerRadius(4)
        }
    }
    
    private var barWidth: CGFloat {
        guard maxCount > 0 else { return 0 }
        let screenWidth = UIScreen.main.bounds.width - 120 // Padding ve diğer elementler için
        let percentage = Double(count) / Double(maxCount)
        return max(CGFloat(percentage) * screenWidth, count > 0 ? 30 : 0)
    }
}

// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    @State static var isPresented = true
    
    static var previews: some View {
        StatisticsView(game: GameModel(), isPresented: $isPresented)
    }
}