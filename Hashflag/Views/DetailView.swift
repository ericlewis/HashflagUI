//
//  DetailView.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/10/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    
    @ObservedObject var campaign: Campaign
    @State private var selectedHashtag: String?
    
    private let formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var body: some View {
        List {
            Section(header: Text("Hashflag")) {
                HStack(spacing: 0) {
                    Spacer()
                    if let animation = campaign.animations?.allObjects.first as? Animated, let url = animation.url {
                        WebImage(url: campaign.imageURL)
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 120, height: 60)
                        Spacer()
                        Divider()
                        Spacer()
                        LottieView(url: url)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 140, height: 140)
                    } else {
                        WebImage(url: campaign.imageURL)
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 140, height: 140)
                    }
                    Spacer()
                }
                .padding(.vertical)
                .listRowInsets(.init())
                NavigationLink(destination: ARViewContainer(url: campaign.imageURL!).edgesIgnoringSafeArea(.all)) {
                    Label("See in AR", systemImage: "arkit")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }
            if let startDate = campaign.startDate, let endDate = campaign.endDate {
                Section(header: Text("Availabile")) {
                    Text("\(startDate, formatter: formatter) - \(endDate, formatter: formatter)")
                        .font(.headline)
                }
            }
            Section(header: Text("Hashtags")) {
                ForEach(campaign.hashtags?.allObjects as? [Hashtag] ?? []) { hashtag in
                    if let value = hashtag.value {
                        Button(action: {
                            UIApplication.shared.open(URL(string: "https://twitter.com/hashtag/\(value)")!, options: [:], completionHandler: nil)
                        }) {
                            Text("#\(Text(value))")
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(Text(campaign.name ?? "No Title"))
    }
}
