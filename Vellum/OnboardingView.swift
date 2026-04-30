//
//  OnboardingView.swift
//  Vellum
//
//  Created by Disha Maheshwari on 4/30/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    let contactEmail = "hello@yourdomain.com"
    let sepiaColor = Color(red: 0.925, green: 0.784, blue: 0.604)
    
    var body: some View {
        ZStack {
            // Full background
            sepiaColor.ignoresSafeArea()
            
            // --- HORIZONTAL MAIN CONTENT (PERFECTLY CENTERED) ---
            HStack(alignment: .center, spacing: 80) {
                
                // LEFT SIDE: Title & Action
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Vellum")
                            .fontDesign(.serif)
                            .font(.system(size: 72, weight: .regular))
                            .foregroundColor(.black)
                        
                        Text("A minimalist space to capture quotes,\nthoughts, and fragments of inspiration.")
                            .fontDesign(.serif)
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Need help or have feedback?")
                            .fontDesign(.serif)
                            .font(.headline)
                            .foregroundColor(.black.opacity(0.6))
                        
                        Link(contactEmail, destination: URL(string: "mailto:\(contactEmail)")!)
                            .fontDesign(.serif)
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Start Journaling")
                            .fontDesign(.serif)
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            // Matched exactly to the other buttons
                            .background(Color.white.opacity(0.4))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .focusEffectDisabled()
                    .padding(.top, 10)
                }
                .frame(maxWidth: 450, alignment: .leading)
                
                // RIGHT SIDE: Commands
                VStack(alignment: .leading, spacing: 35) {
                    OnboardingRow(icon: "hand.draw", title: "Trackpad Scroll", desc: "Navigate effortlessly through your timeline.")
                    OnboardingRow(icon: "arrow.left.and.right.square", title: "⌘ + Arrows", desc: "Change the background canvas color.")
                    OnboardingRow(icon: "return", title: "Press Enter", desc: "Instantly save your current quote.")
                    OnboardingRow(icon: "option", title: "Option + Enter", desc: "Drop to a new line natively inside text fields.")
                    OnboardingRow(icon: "calendar", title: "Backdate", desc: "Log a thought from the past using the toolbar.")
                }
                .frame(maxWidth: 450, alignment: .leading)
            }
            .padding(.horizontal, 60)
            
            // --- TOP LEFT BACK BUTTON (Identical Twin) ---
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.black)
                    .padding(14)
                    .background(Color.white.opacity(0.4))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .focusable(false)
            .focusEffectDisabled()
            .padding(.leading, 40)
            .padding(.top, 30)
        }
    }
}

struct OnboardingRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.black)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontDesign(.serif)
                    .font(.title3)
                    .foregroundColor(.black)
                Text(desc)
                    .fontDesign(.serif)
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.7))
            }
        }
    }
}
