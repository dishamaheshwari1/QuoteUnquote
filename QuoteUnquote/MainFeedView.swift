//
//  MainFeedView.swift
//  Quote Unquote
//
//  Created by Disha Maheshwari on 4/29/26.
//

import SwiftUI
import SwiftData

struct MainFeedView: View {
    var startID: UUID?
    var isFromLibrary: Bool = false
    
    @Query(sort: \Quote.dateCreated, order: .forward) private var historyQuotes: [Quote]
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    @State private var showOnboarding = false
    @State private var showGallery = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(historyQuotes) { quote in
                                QuoteEditorView(
                                    quote: quote,
                                    isFromLibrary: isFromLibrary,
                                    onGalleryClick: { showGallery = true }
                                )
                                .frame(width: geo.size.width, height: geo.size.height)
                                .id(quote.id) // Crucial for scrolling to work
                            }
                            
                            QuoteEditorView(
                                quote: nil,
                                isFromLibrary: isFromLibrary,
                                onGalleryClick: { showGallery = true }
                            )
                            .frame(width: geo.size.width, height: geo.size.height)
                            .id("NEW_ENTRY")
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    .onAppear {
                        // SMART SCROLLING:
                        // If we come from the Gallery, scroll to the specific quote.
                        // Otherwise, go to the blank new entry.
                        if let target = startID {
                            proxy.scrollTo(target, anchor: .center)
                        } else {
                            proxy.scrollTo("NEW_ENTRY", anchor: .bottom)
                        }
                        
                        if !hasSeenOnboarding {
                            showOnboarding = true
                            hasSeenOnboarding = true
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .navigationDestination(isPresented: $showOnboarding) { OnboardingView() }
            .navigationDestination(isPresented: $showGallery) { GalleryView() }
        }
    }
}
