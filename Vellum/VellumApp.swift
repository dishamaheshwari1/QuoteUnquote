//
//  VellumApp.swift
//  Vellum
//
//  Created by Disha Maheshwari on 4/29/26.
//

import SwiftUI
import SwiftData

@main
struct VellumApp: App {
    
    // 1. We create a secure connection to your shared Widget folder
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
        // 2. Your Main App Window
        WindowGroup {
            MainFeedView()
        }
        // 3. We attach the shared database to the main app so it saves in the right place!
        .modelContainer(sharedModelContainer)
    }
}
