//
//  Hashflag_Widgets.swift
//  Hashflag Widgets
//
//  Created by Eric Lewis on 9/9/20.
//

import WidgetKit
import SwiftUI
import Intents
import SDWebImageSwiftUI

struct Provider: IntentTimelineProvider {
    init() {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.hashflag")?.path
        let cache = SDImageCache(namespace: "Hashflag",
                                 diskCacheDirectory: path)
        
        SDImageCachesManager.shared.addCache(cache)
        SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
        SDWebImageManager.shared.transformer = SDImageResizingTransformer(size: CGSize(width: 300, height: 300),
                                                                          scaleMode: .fill)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), campaign: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, campaign: nil)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let result = try? PersistenceController.shared.container.viewContext.fetch(FetchRequests.alphabetical()).randomElement()
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let entry = SimpleEntry(date: entryDate, configuration: configuration, campaign: result)
        
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let campaign: Campaign?
}

struct Hashflag_WidgetsEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let campaign = entry.campaign, let url = campaign.imageURL, let imageData = try? Data(contentsOf: url),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .padding()
                .widgetURL(campaign.imageURL)
        }
        else {
            Text("No Hashflag")
        }
    }
}

@main
struct Hashflag_Widgets: Widget {
    let kind: String = "Hashflag_Widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Hashflag_WidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Random Hashflag")
        .description("Display a random Hashflag. Tapping the widget will bring you to the application for more information.")
        .supportedFamilies([.systemSmall])
    }
}
