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
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainFeedView()
            }
            // Hides the standard macOS top title bar to give it that immersive, clean look
            .toolbar(.hidden, for: .windowToolbar)
        }
        // This automatically sets up the SwiftData database for the Quote model
        .modelContainer(for: Quote.self)
    }
}
