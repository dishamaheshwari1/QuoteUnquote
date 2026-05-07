//
//  QuoteUnquoteWidget.swift
//  QuoteUnquoteWidget
//
//  Created by Disha Maheshwari on 4/30/26.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// 1. THE REFRESH BUTTON LOGIC
struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Quote"
    
    func perform() async throws -> some IntentResult {
        // Forces the Mac to reload the widget immediately
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// 2. THE DATA PROVIDER
struct Provider: TimelineProvider {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Quote.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.maheshwariDisha.vellum")
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let context = ModelContext(sharedModelContainer)
        let descriptor = FetchDescriptor<Quote>()
        let allQuotes = (try? context.fetch(descriptor)) ?? []
        
        let randomQuote = allQuotes.randomElement()
        let entry = SimpleEntry(date: Date(), quote: randomQuote)
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: Quote?
}

// 3. THE VISUAL UI
struct QuoteUnquoteWidgetEntryView : View {
    var entry: Provider.Entry
    
    let backgroundColors: [Color] = [
        Color(red: 0.925, green: 0.784, blue: 0.604),
        Color(red: 0.6, green: 0.05, blue: 0.1),
        Color(red: 0.8, green: 0.3, blue: 0.0),
        Color(red: 0.95, green: 0.75, blue: 0.1),
        Color(red: 0.0, green: 0.4, blue: 0.25),
        Color(red: 0.05, green: 0.2, blue: 0.5),
        Color(red: 0.35, green: 0.1, blue: 0.55),
        Color(red: 0.35, green: 0.2, blue: 0.05),
        Color(red: 0.25, green: 0.3, blue: 0.35),
        Color.black
    ]

    var body: some View {
        let colorIndex = entry.quote?.colorIndex ?? 0
        let isLight = colorIndex == 0 || colorIndex == 3
        
        ZStack(alignment: .bottomTrailing) {
            // THE FIX: We removed the internal background layer to stop the "White Block"
            
            VStack {
                if let quote = entry.quote {
                    Text(quote.text)
                        .fontDesign(.serif)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(isLight ? .black : .white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                    
                    if !quote.note.isEmpty {
                        Text("— \(quote.note)")
                            .fontDesign(.serif)
                            .font(.system(size: 14, weight: .regular))
                            .italic()
                            .foregroundColor(isLight ? .black.opacity(0.6) : .white.opacity(0.6))
                            .padding(.top, 4)
                    }
                } else {
                    Text("No quotes yet.\nOpen app to add some!")
                        .fontDesign(.serif)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // THE REFINED BUTTON: Shrunk the frame to make the circle smaller
            Button(intent: RefreshQuoteIntent()) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 8, weight: .bold)) // Your size 8 icon
                    .foregroundColor(isLight ? .black.opacity(0.4) : .white.opacity(0.5))
                    .frame(width: 18, height: 18) // THE FIX: This shrinks the circle background
                    .background(isLight ? Color.black.opacity(0.06) : Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4) // Nudges it closer to the actual corner
            .padding(.bottom, 4)
        }
        // THE TRUE BACKGROUND: This fills the whole widget edge-to-edge
        .containerBackground(entry.quote != nil ? backgroundColors[colorIndex] : Color.black.opacity(0.8), for: .widget)
    }
}

// 4. THE MAIN WIDGET DEFINITION
@main
struct QuoteUnquoteWidget: Widget {
    let kind: String = "QuoteUnquoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteUnquoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quote Unquote")
        .description("Displays a random quote from your journal.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
