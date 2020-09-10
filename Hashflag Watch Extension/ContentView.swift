//
//  ContentView.swift
//  Hashflag Watch Extension
//
//  Created by Eric Lewis on 9/9/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    @FetchRequest(fetchRequest: FetchRequests.alphabetical()) var results

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                ForEach(results) { campaign in
                    WebImage(url: campaign.imageURL)
                        .resizable()
                        .transition(.fade)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding()
        }
        .navigationTitle("Hashflags")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
