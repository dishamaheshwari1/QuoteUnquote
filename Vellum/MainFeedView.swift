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
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        
                        // 1. HISTORY FEED
                        ForEach(historyQuotes) { quote in
                            QuoteEditorView(quote: quote, isFromLibrary: isFromLibrary)
                                // Strict absolute sizing
                                .frame(width: geo.size.width, height: geo.size.height)
                                .id(quote.id)
                        }
                        
                        // 2. NEW ENTRY
                        QuoteEditorView(quote: nil, isFromLibrary: isFromLibrary)
                            // Strict absolute sizing
                            .frame(width: geo.size.width, height: geo.size.height)
                            .id("NEW_ENTRY")
                    }
                    .scrollTargetLayout()
                }
                // THE FIX: Strict paging with no state-binding interruptions
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                // Prevent bouncing past the first/last quotes which messes up trackpad math
                .scrollBounceBehavior(.basedOnSize)
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
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}
