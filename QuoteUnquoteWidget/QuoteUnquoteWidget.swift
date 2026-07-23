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

// MARK: - 1. THE REFRESH BUTTON LOGIC
struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Quote"
    
    func perform() async throws -> some IntentResult {
        // Forces the Mac to reload the widget immediately
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - 2. WIDGET CONFIGURATION INTENTS
struct SingleTagIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Filter by Tag"
    static var description = IntentDescription("Displays quotes that match a specific tag.")

    @Parameter(title: "Tag (e.g., #inspiration)")
    var tag: String?
}

struct MultipleTagsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Filter by Multiple Tags"
    static var description = IntentDescription("Displays quotes that match any of the provided tags.")

    @Parameter(title: "Tags separated by space (e.g., #life #tech)")
    var tags: String?
}

// MARK: - 3. SHARED DATABASE HELPER
// We use a shared helper so we don't have to rewrite the ModelContainer logic three times.
struct WidgetDataHelper {
    static let sharedContainer: ModelContainer = {
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
    
    static func fetchAllQuotes() -> [Quote] {
        let context = ModelContext(sharedContainer)
        let descriptor = FetchDescriptor<Quote>()
        return (try? context.fetch(descriptor)) ?? []
    }
}

// MARK: - 4. THE DATA PROVIDERS

// Provider for the General Widget (Cycles through everything)
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), quote: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let allQuotes = WidgetDataHelper.fetchAllQuotes()
        let randomQuote = allQuotes.randomElement()
        let entry = SimpleEntry(date: Date(), quote: randomQuote)
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// Provider for the Single Tag Widget
struct SingleTagProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: nil)
    }

    func snapshot(for configuration: SingleTagIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), quote: nil)
    }

    func timeline(for configuration: SingleTagIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let allQuotes = WidgetDataHelper.fetchAllQuotes()
        
        // Filter by the single tag if the user provided one
        let filteredQuotes = allQuotes.filter { quote in
            guard let searchTag = configuration.tag?.lowercased().trimmingCharacters(in: .whitespaces) else { return true }
            guard !searchTag.isEmpty else { return true }
            return quote.tags.lowercased().contains(searchTag)
        }
        
        let randomQuote = filteredQuotes.randomElement()
        let entry = SimpleEntry(date: Date(), quote: randomQuote)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// Provider for the Multiple Tags Widget
struct MultipleTagsProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: nil)
    }

    func snapshot(for configuration: MultipleTagsIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), quote: nil)
    }

    func timeline(for configuration: MultipleTagsIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let allQuotes = WidgetDataHelper.fetchAllQuotes()
        
        // Filter by multiple tags (shows quote if it contains ANY of the tags)
        let filteredQuotes = allQuotes.filter { quote in
            guard let searchTagsRaw = configuration.tags?.lowercased() else { return true }
            let searchTags = searchTagsRaw.split(separator: " ").map { String($0) }
            guard !searchTags.isEmpty else { return true }
            
            // Check if the quote's tags contain at least one of the search tags
            let quoteTagsLowercased = quote.tags.lowercased()
            return searchTags.contains { quoteTagsLowercased.contains($0) }
        }
        
        let randomQuote = filteredQuotes.randomElement()
        let entry = SimpleEntry(date: Date(), quote: randomQuote)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: Quote?
}

// MARK: - 5. THE VISUAL UI
struct QuoteUnquoteWidgetEntryView : View {
    var entry: SimpleEntry
    
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
            VStack {
                if let quote = entry.quote {
                    // NEW: Display the tags if they exist
                    if !quote.tags.isEmpty {
                        Text(quote.tags)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(isLight ? .black.opacity(0.5) : .white.opacity(0.5))
                            .padding(.bottom, 4)
                    }
                    
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
                    Text("No quotes match.\nOpen app to add some!")
                        .fontDesign(.serif)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(intent: RefreshQuoteIntent()) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isLight ? .black.opacity(0.4) : .white.opacity(0.5))
                    .frame(width: 18, height: 18)
                    .background(isLight ? Color.black.opacity(0.06) : Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 4)
            .padding(.bottom, 4)
        }
        .containerBackground(entry.quote != nil ? backgroundColors[colorIndex] : Color.black.opacity(0.8), for: .widget)
    }
}

// MARK: - 6. THE WIDGET DEFINITIONS

struct QuoteUnquoteWidget: Widget {
    let kind: String = "QuoteUnquoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteUnquoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("General Quotes")
        .description("Displays a random quote from your entire journal.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct SingleTagWidget: Widget {
    let kind: String = "SingleTagWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SingleTagIntent.self, provider: SingleTagProvider()) { entry in
            QuoteUnquoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Single Tag Filter")
        .description("Cycles through quotes matching one specific tag.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct MultipleTagsWidget: Widget {
    let kind: String = "MultipleTagsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MultipleTagsIntent.self, provider: MultipleTagsProvider()) { entry in
            QuoteUnquoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Multiple Tags Filter")
        .description("Cycles through quotes matching any of the provided tags.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - 7. THE WIDGET BUNDLE
// This groups all three widgets together so they all appear in the Mac widget gallery.
@main
struct QuoteUnquoteWidgets: WidgetBundle {
    var body: some Widget {
        QuoteUnquoteWidget()
        SingleTagWidget()
        MultipleTagsWidget()
    }
}
