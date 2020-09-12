//
//  ContentView.swift
//  Hashflag Watch Extension
//
//  Created by Eric Lewis on 9/9/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    @ObservedObject var campaign: Campaign
    
    private let formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    @State private var selected = 0
    
    var body: some View {
        TabView(selection: $selected) {
            makeList()
                .tag(0)
            makeImage()
                .tag(1)
        }
        .navigationTitle(campaign.name ?? "No Title")
    }
    
    func makeImage() -> some View {
        Button(action: {
            selected = 0
        }) {
            WebImage(url: campaign.imageURL)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func makeList() -> some View {
        List {
            Button(action: {
                selected = 1
            }) {
                HStack {
                    Spacer()
                    WebImage(url: campaign.imageURL)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 80)
                        .padding(.vertical)
                    Spacer()
                }
            }
            if let name = campaign.name, let startDate = campaign.startDate, let endDate = campaign.endDate {
                Section(header: Text("Campaign & Dates")) {
                    Text(name)
                        .font(.headline)
                    Text("\(startDate, formatter: formatter) - \(endDate, formatter: formatter)")
                        .font(.headline)
                }
            }
            Section(header: Text("Hashtags")) {
                ForEach(campaign.hashtags?.allObjects as? [Hashtag] ?? []) { hashtag in
                    if let value = hashtag.value {
                        Text("#\(Text(value))")
                            .font(.headline)
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @FetchRequest(fetchRequest: FetchRequests.alphabetical()) var alphabetical
    @FetchRequest(fetchRequest: FetchRequests.latest()) var latest
    @FetchRequest(fetchRequest: FetchRequests.endingSoon()) var endingSoon
    
    @State private var sort: SelectedSort = .alphabetical
    
    private var results: FetchedResults<Campaign> {
        switch sort {
        case .alphabetical:
            return alphabetical
        case .endingSoon:
            return endingSoon
        case .latest:
            return latest
        }
    }
    
    @State var showSort = false
    
    var body: some View {
        TabView {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(results) { campaign in
                        NavigationLink(destination: DetailView(campaign: campaign)) {
                            WebImage(url: campaign.imageURL)
                                .resizable()
                                .transition(.fade)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            Form {
                Picker("Sort", selection: $sort.animation()) {
                    ForEach(SelectedSort.allCases) {
                        Text($0.rawValue.localizedCapitalized).tag($0)
                    }
                }
            }
        }
        .navigationTitle("Hashflags")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
