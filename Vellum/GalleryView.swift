//
//  GalleryView.swift
//  Vellum
//
//  Created by Disha Maheshwari on 4/29/26.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(sort: \Quote.dateCreated, order: .reverse) private var quotes: [Quote]
    @Environment(\.dismiss) private var dismiss
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604), // Sepia
        Color(red: 0.6, green: 0.05, blue: 0.1),      // Ruby
        Color(red: 0.8, green: 0.3, blue: 0.0),       // Orange
        Color(red: 0.95, green: 0.75, blue: 0.1),     // Yellow
        Color(red: 0.0, green: 0.4, blue: 0.25),      // Emerald
        Color(red: 0.05, green: 0.2, blue: 0.5),      // Sapphire
        Color(red: 0.35, green: 0.1, blue: 0.55),     // Purple
        Color(red: 0.35, green: 0.2, blue: 0.05),     // Brown
        Color(red: 0.25, green: 0.3, blue: 0.35),     // Slate
        Color.black
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // --- CUSTOM ULTRA-SLEEK HEADER ---
            ZStack {
                Text("My Quotes")
                    .fontDesign(.serif)
                    .font(.title3)
                    .foregroundColor(.white)
                
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
            .background(Color.black.ignoresSafeArea(edges: .top))
            
            // --- THE GRID ---
            ScrollView {
                if quotes.isEmpty {
                    ContentUnavailableView("No Quotes Yet", systemImage: "text.book.closed")
                        .padding(.top, 50)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(quotes) { quote in
                            NavigationLink(destination: MainFeedView(startID: quote.id, isFromLibrary: true)) {
                                QuoteGridItem(quote: quote, color: backgroundColors[quote.colorIndex])
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

// Subview for the Grid Tile Look
struct QuoteGridItem: View {
    let quote: Quote
    let color: Color
    
    var isLight: Bool { quote.colorIndex == 0 || quote.colorIndex == 3 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // 1. TOP: The Caption
            if !quote.note.isEmpty {
                Text(quote.note)
                    .fontDesign(.serif)
                    .font(.subheadline)
                    .italic()
                    .lineLimit(1)
                    .foregroundColor(isLight ? .black.opacity(0.7) : .white.opacity(0.7))
            } else {
                Text(" ")
                    .font(.subheadline)
            }
            
            // 2. MIDDLE: The Actual Quote
            Text(quote.text)
                .fontDesign(.serif)
                .font(.system(size: 26))
                .minimumScaleFactor(0.3)
                .multilineTextAlignment(.leading)
                .foregroundColor(isLight ? .black : .white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // 3. BOTTOM: Date
            Text(quote.dateCreated.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(isLight ? .black.opacity(0.6) : .white.opacity(0.6))
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }
}
