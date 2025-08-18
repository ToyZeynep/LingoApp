//
//  GuessDistributionRow.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

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
        let maxWidth: CGFloat = 200
        let percentage = Double(count) / Double(maxCount)
        return max(CGFloat(percentage) * maxWidth, count > 0 ? 40 : 0)
    }
}
