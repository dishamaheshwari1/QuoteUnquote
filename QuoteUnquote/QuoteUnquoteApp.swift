//
//  QuoteUnquoteApp.swift
//  Quote Unquote
//
//  Created by Disha Maheshwari on 4/29/26.
//

import SwiftUI
import SwiftData
import Sparkle
import Combine

// The controller that manages the Sparkle background checks
class UpdaterViewModel: ObservableObject {
    @Published var canCheckForUpdates = false
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}

@main
struct QuoteUnquoteApp: App {
    @StateObject private var updaterViewModel = UpdaterViewModel()
    
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
        .defaultSize(width: 820, height: 520)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updaterViewModel.checkForUpdates()
                }
                .disabled(!updaterViewModel.canCheckForUpdates)
            }
        }
    }
}
