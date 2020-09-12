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
                Text("Lottie")
                Text("SDWebImage")
                Text("SDWebImageSwiftUI")
            }
            Section(header: Text("Cache")) {
                Button(action: {
                    SDImageCachesManager.shared.caches?.forEach {
                        $0.clear(with: .all, completion: nil)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Clear Images")
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
