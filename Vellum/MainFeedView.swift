//
//  MainFeedView.swift
//  Vellum
//
//  Created by Disha Maheshwari on 4/29/26.
//

import SwiftUI
import SwiftData

struct MainFeedView: View {
    @Query(sort: \Quote.dateCreated, order: .forward) private var historyQuotes: [Quote]
    
    var startID: UUID?
    var isFromLibrary: Bool = false
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var navigateToOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0) {
                            ForEach(historyQuotes) { quote in
                                QuoteEditorView(quote: quote, isFromLibrary: isFromLibrary)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .id(quote.id)
                            }
                            
                            QuoteEditorView(quote: nil, isFromLibrary: isFromLibrary)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .id("NEW_ENTRY")
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)
                    .onAppear {
                        if let target = startID {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(target, anchor: .center)
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo("NEW_ENTRY", anchor: .bottom)
                            }
                        }
                        
                        // First launch check
                        if !hasSeenOnboarding {
                            navigateToOnboarding = true
                            hasSeenOnboarding = true
                        }
                    }
                }
            }
            .ignoresSafeArea(.all)
            
            // --- TOP RIGHT HELP CAPSULE ---
            .overlay(alignment: .topTrailing) {
                Button(action: { navigateToOnboarding = true }) {
                    Image(systemName: "questionmark")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.black)
                        .padding(14)
                        .background(Color.white.opacity(0.4))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .focusable(false)
                .focusEffectDisabled()
                .padding(.trailing, 40) // EXACT match to share button horizontal 40
                .padding(.top, 30) // Symmetrical with traffic lights
            }
        } .navigationDestination(isPresented: $navigateToOnboarding) {OnboardingView()}
    }
}
