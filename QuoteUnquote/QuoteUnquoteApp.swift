//
//  QuoteUnquoteApp.swift
//  Quote Unquote
//
//  Created by Disha Maheshwari on 4/29/26.
//

import SwiftUI
import SwiftData

@main
struct QuoteUnquoteApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Quote.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, groupContainer: .identifier("group.com.maheshwariDisha.vellum"))
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainFeedView()
        }
        .windowStyle(.hiddenTitleBar)
        .modelContainer(sharedModelContainer)
    }
}
