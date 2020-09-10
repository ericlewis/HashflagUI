//
//  FilterSortView.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/10/20.
//

import SwiftUI

struct FilterSortView: View {
    @Binding var selectedFilter: SelectedFilter
    @Binding var selectedSort: SelectedSort

    var body: some View {
        Form {
            Section(header: Text("Filter")) {
                CheckmarkButton("All", selected: selectedFilter == .all) { selectedFilter = .all }
                CheckmarkButton("Animated", selected: selectedFilter == .animated) { selectedFilter = .animated }
            }
            Section(header: Text("Sort")) {
                CheckmarkButton("Alphabetical", selected: selectedSort == .alphabetical) { selectedSort = .alphabetical }
                CheckmarkButton("Latest", selected: selectedSort == .latest) { selectedSort = .latest }
                CheckmarkButton("Ending Soon", selected: selectedSort == .endingSoon) { selectedSort = .endingSoon }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Filter & Sort")
    }
}

struct CheckmarkButton: View {
    let text: LocalizedStringKey
    let selected: Bool
    let action: () -> ()
    
    init(_ text: LocalizedStringKey, selected: Bool = false, action: @escaping () -> ()) {
        self.text = text
        self.selected = selected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text(text)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
