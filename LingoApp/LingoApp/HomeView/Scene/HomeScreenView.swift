//
//  HomeScreenView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//

import SwiftUI

struct HomeScreenView: View {
    @Binding var soundEnabled: Bool
    @State private var showSettings = false
    @State private var showStatistics = false
    @State private var showHowToPlay = false
    @State private var animateTitle = false
    @State private var animateButtons = false
    
    let onPlayTapped: () -> Void

    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version)"
        } else if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return "1.0"
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 15) {
                        Button(action: {
                            showStatistics = true
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        
                        Button(action: {
                            showHowToPlay = true
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .blue, .indigo],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: .cyan.opacity(0.5), radius: 20, x: 0, y: 10)
                            
                            Text("WL")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animateTitle ? 1.0 : 0.8)
                        .animation(.spring(response: 1.2, dampingFraction: 0.8), value: animateTitle)
                        
                        Text("WORD LINGO")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            .offset(y: animateTitle ? 0 : 20)
                            .opacity(animateTitle ? 1 : 0)
                            .animation(.easeOut(duration: 1.0).delay(0.3), value: animateTitle)
                        
                        Text("Kelime Tahmin Oyunu".localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .offset(y: animateTitle ? 0 : 10)
                            .opacity(animateTitle ? 1 : 0)
                            .animation(.easeOut(duration: 0.8).delay(0.6), value: animateTitle)
                    }
                    
                    Spacer().frame(height: 80)
                    
                    VStack(spacing: 20) {
                        Button(action: onPlayTapped) {
                            Text("OYNA".localized)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .blue.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 8)
                                )
                        }
                        .scaleEffect(animateButtons ? 1.0 : 0.8)
                        .opacity(animateButtons ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.9), value: animateButtons)
                        

                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
                
                VStack(spacing: 5) {
                    // FIX
                    Text("Sürüm \(appVersion)".localized)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("© 2025 Word Lingo")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            animateTitle = true
            animateButtons = true
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(soundEnabled: $soundEnabled)
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView(statisticsManager: StatisticsManager.shared, isPresented: $showStatistics)
        }
        .sheet(isPresented: $showHowToPlay) {
            HowToPlayView()
        }
    }
}

// MARK: - Preview
struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView(soundEnabled: .constant(true)) {
            print("Play tapped")
        }
    }
}
