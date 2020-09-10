//
//  SettingsView.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/10/20.
//

import SwiftUI
import SDWebImage

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Acknowledgements")) {
                Text("BetterSafariView")
                Text("Lottie")
                Text("SDWebImage")
                Text("SDWebImageSwiftUI")
            }
            Section(header: Text("Cache")) {
                Button(action: {
                    
                }) {
                    HStack {
                        Spacer()
                        Text("Clear Hashflag Cache")
                        Spacer()
                    }
                    .foregroundColor(.red)
                    .listRowInsets(.init())
                }
                Button(action: {
                    SDImageCachesManager.shared.caches?.forEach {
                        $0.clear(with: .all, completion: nil)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Clear Image Cache")
                        Spacer()
                    }
                    .foregroundColor(.red)
                    .listRowInsets(.init())
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
    }
}
