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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainFeedView()
            }
            .toolbar(.hidden, for: .windowToolbar)
            // 1. Set the absolute minimum size the user can shrink it to
            .frame(minWidth: 480, minHeight: 365)
        }
        .modelContainer(sharedModelContainer)
        // 2. Set the default size when the app is first launched
        .defaultSize(width: 980, height: 620)
    }
}
