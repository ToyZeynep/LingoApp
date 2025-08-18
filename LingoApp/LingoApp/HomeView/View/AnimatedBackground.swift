//
//  AnimatedBackground.swift
//  LingoApp
//
//  Created by Zeynep Toy on 18.08.2025.
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.2, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Circle()
                .fill(.cyan.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(
                    x: animate ? -80 : -120,
                    y: animate ? -150 : -200
                )
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
            
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: 150, height: 150)
                .blur(radius: 50)
                .offset(
                    x: animate ? 100 : 140,
                    y: animate ? 120 : 180
                )
                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: animate)
            
            Circle()
                .fill(.indigo.opacity(0.1))
                .frame(width: 180, height: 180)
                .blur(radius: 70)
                .offset(
                    x: animate ? -60 : -20,
                    y: animate ? 200 : 160
                )
                .animation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: animate)
            
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 4, height: 4)
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : CGFloat.random(in: -100...100),
                        y: animate ? CGFloat.random(in: -300...300) : CGFloat.random(in: -200...200)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}
