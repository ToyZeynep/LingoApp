//
//  SettingsView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 10.08.2025.
//

import SwiftUI

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
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            let v = UserDefaults.standard.object(forKey: "SoundEnabled") == nil
            ? true
            : UserDefaults.standard.bool(forKey: "SoundEnabled")
            soundEnabled = v
        }
        .onChange(of: soundEnabled) { newValue in
            UserDefaults.standard.set(newValue, forKey: "SoundEnabled")
            SoundEngine.shared.enabled = newValue
        }
    }
}
