//
//  CustomAlertView.swift
//  LingoApp
//
//  Created by Zeynep Toy on 10.08.2025.
//


import SwiftUI

struct CustomAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void
    var secondaryButtonTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil
    var icon: String? = nil
    var iconColor: Color = .cyan
    var wordMeaning: String? = nil
    
    @Binding var isPresented: Bool
    @State private var appear = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                }
            
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 45))
                            .foregroundColor(iconColor)
                            .shadow(color: iconColor.opacity(0.5), radius: 10)
                            .scaleEffect(appear ? 1.0 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appear)
                    }
                    
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 25)
                .padding(.horizontal, 20)

                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
                if let wordMeaning = wordMeaning, !wordMeaning.isEmpty {
                    VStack(spacing: 5) {
                        
                        Text("Kelimenin Anlamı:")
                            .font(.system(size: 14, weight: .semibold))
                        
                        
                        Text(wordMeaning)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(2)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        primaryAction()
                        dismissAlert()
                    }) {
                        Text(primaryButtonTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    colors: [.cyan, .cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    if let secondaryTitle = secondaryButtonTitle {
                        Button(action: {
                            secondaryAction?()
                            dismissAlert()
                        }) {
                            Text(secondaryTitle)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.15, blue: 0.3),
                                Color(red: 0.05, green: 0.1, blue: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 15)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
                appear = true
            }
        }
    }
    
    private func dismissAlert() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.9
            opacity = 0
            appear = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}
