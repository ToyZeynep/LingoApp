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
    
    var body: some View {
        ZStack {
            // Animated Background
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Top Bar - Icons Left, Settings Right
                HStack {
                    // Left side icons
                    HStack(spacing: 15) {
                        // Statistics Button
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
                        
                        // How to Play Button
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
                    
                    // Settings Button
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
                
                // App Title with Animation
                VStack(spacing: 20) {
                    // Logo/Title Area
                    VStack(spacing: 15) {
                        // App Icon
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
                            
                            Text("L")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animateTitle ? 1.0 : 0.8)
                        .animation(.spring(response: 1.2, dampingFraction: 0.8), value: animateTitle)
                        
                        // App Name
                        Text("LINGO")
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
                        
                        Text("Kelime Tahmin Oyunu")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .offset(y: animateTitle ? 0 : 10)
                            .opacity(animateTitle ? 1 : 0)
                            .animation(.easeOut(duration: 0.8).delay(0.6), value: animateTitle)
                    }
                    
                    Spacer().frame(height: 80)
                    
                    // Main Menu Buttons
                    VStack(spacing: 20) {
                        // Play Button
                        Button(action: onPlayTapped) {
                            Text("OYNA")
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
                
                // Bottom Info
                VStack(spacing: 5) {
                    Text("Sürüm 1.0")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("© 2025 Lingo App")
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

// MARK: - Animated Background
struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4),
                    Color(red: 0.1, green: 0.2, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated orbs
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
            
            // Floating particles
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

// MARK: - Settings View
struct SettingsView: View {
    @Binding var soundEnabled: Bool
    @Environment(\.dismiss) private var dismiss
    
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
                
                VStack(spacing: 30) {
                    // Settings Title
                    Text("Ayarlar")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Settings Options
                    VStack(spacing: 20) {
                        // Sound Toggle
                        HStack {
                            Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                                .frame(width: 30)
                            
                            Text("Ses Efektleri")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Toggle("", isOn: $soundEnabled)
                                .scaleEffect(0.8)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                    .font(.system(size: 16, weight: .semibold))
                }
            }
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
