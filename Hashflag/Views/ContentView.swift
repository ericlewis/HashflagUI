//
//  ContentView.swift
//  Shared
//
//  Created by Eric Lewis on 9/8/20.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

enum SelectedFilter {
    case all, animated
}

enum SelectedSort {
    case alphabetical, latest, endingSoon
}

struct ContentView: View {
    enum SheetType: Identifiable {
        case settings, filterSort
        
        var id: Self {
            self
        }
    }
    
    @FetchRequest(fetchRequest: FetchRequests.alphabetical()) var alphabetical
    @FetchRequest(fetchRequest: FetchRequests.latest()) var latest
    @FetchRequest(fetchRequest: FetchRequests.endingSoon()) var endingSoon
    
    @StateObject private var searchBar: SearchBar = SearchBar()
    
    @State private var selectedCampaign: Campaign?
    @State private var sheet: SheetType?
    @State private var selectedFilter: SelectedFilter = .all
    @State private var selectedSort: SelectedSort = .alphabetical
    
    private var results: FetchedResults<Campaign> {
        switch selectedSort {
        case .alphabetical:
            return alphabetical
        case .latest:
            return latest
        case .endingSoon:
            return endingSoon
        }
    }
    
    private func setSheet(_ selectedSheet: SheetType) -> () -> () {
        {
            sheet = selectedSheet
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 88))]) {
                    ForEach(
                        results
                        .filter {
                            selectedFilter == .animated ? $0.animations?.count ?? 0 > 0 : true
                        }
                        .filter {
                            searchBar.text.isEmpty ? true : $0.name?.lowercased().contains(searchBar.text.lowercased()) ?? true
                        }
                    ) { campaign in
                        NavigationLink(destination: DetailView(campaign: campaign)) {
                            WebImage(url: campaign.imageURL)
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .onOpenURL { url in
                selectedCampaign = results.first { $0.imageURL == url }
            }
            .sheet(item: $selectedCampaign) { campaign in
                NavigationView {
                    DetailView(campaign: campaign)
                        .toolbar {
                            ToolbarItem {
                                Button("Dismiss") {
                                    selectedCampaign = nil
                                }
                            }
                        }
                }
            }
            .navigationTitle("Hashflags")
            .add(self.searchBar)
            .toolbar {
                #if !targetEnvironment(macCatalyst)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: setSheet(.settings)) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                #endif
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: setSheet(.filterSort)) {
                        Label("Filter & Sort", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            DetailPlaceholder()
        }
        .sheet(item: $sheet) { selectedSheet in
            NavigationView {
                Group {
                    switch selectedSheet {
                    case .settings:
                        SettingsView()
                    case .filterSort:
                        FilterSortView(selectedFilter: $selectedFilter,
                                       selectedSort: $selectedSort)
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button("Done") {
                            sheet = nil
                        }
                    }
                }
            }
        }
    }
}
