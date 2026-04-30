//
//  VellumWidget.swift
//  VellumWidget
//
//  Created by Disha Maheshwari on 4/30/26.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// 1. The Interactive Button Logic (macOS Sonoma Feature)
struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Quote"
    
    func perform() async throws -> some IntentResult {
        // This tells the Mac to instantly reload the widget timeline
        return .result()
    }
}

// 2. The Timeline Provider (Controls the 6-hour refresh)
struct Provider: TimelineProvider {
    // Tells the widget how to connect to our shared App Group database
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Quote.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, groupContainer: .identifier("group.com.maheshwariDisha.vellum"))
        do {
            return try ModelContainer(for: Schema([Quote.self]), configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), quote: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Fetch all quotes directly from the shared database
        let context = ModelContext(sharedModelContainer)
        let descriptor = FetchDescriptor<Quote>()
        let allQuotes = (try? context.fetch(descriptor)) ?? []
        
        let randomQuote = allQuotes.randomElement()
        
        // Schedule the next auto-refresh for 6 hours from now
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let entry = SimpleEntry(date: Date(), quote: randomQuote)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: Quote?
}

// 3. The Visual Widget UI
struct VellumWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Main Text Content
            VStack {
                if let quote = entry.quote {
                    Text(quote.text)
                        .fontDesign(.serif)
                        .font(.system(size: 26, weight: .regular)) // explicitly regular
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.4)
                    
                    if !quote.note.isEmpty {
                        Text("— \(quote.note)")
                            .fontDesign(.serif)
                            .font(.system(size: 16, weight: .regular)) // explicitly regular
                            .italic()
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                } else {
                    Text("No quotes yet.\nOpen Vellum to add some!")
                        .fontDesign(.serif)
                        .font(.system(size: 16, weight: .regular)) // No more bold .headline
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Reload button forced to the absolute bottom right corner
            .overlay(alignment: .bottomTrailing) {
                Button(intent: RefreshQuoteIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 8, weight: .regular)) // Much smaller, thinner icon
                }
                .buttonStyle(.plain)
                .padding(7)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(.trailing, -4) // Nudges it closer to the edge
                .padding(.bottom, -4)  // Nudges it closer to the edge
            }
        }
        .containerBackground(.thinMaterial, for: .widget)
    }
}

// 4. The Widget Configuration
@main
struct VellumWidget: Widget {
    let kind: String = "VellumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VellumWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vellum Quote")
        .description("Displays a random quote from your journal.")
        .supportedFamilies([.systemMedium, .systemLarge]) // Supports desktop sizes
    }
}
