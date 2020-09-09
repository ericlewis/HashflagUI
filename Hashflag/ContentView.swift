//
//  ContentView.swift
//  Shared
//
//  Created by Eric Lewis on 9/8/20.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import Lottie
import BetterSafariView

struct LottieView: UIViewRepresentable {
    @State var url: URL
    var loopMode: LottieLoopMode = .playOnce
    var animationView = AnimationView()

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()

        Lottie.Animation.loadedFrom(url: url, closure: { self.animationView.animation = $0 }, animationCache: nil)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        animationView.play()
    }
}

struct DetailView: View {
    @EnvironmentObject var model: ViewModel
    
    let tagKey: String
    
    @State var selectedHashtag: String?
    
    var body: some View {
        if let tags = model.groupedTags[tagKey], let firstTag = tags.first {
            List {
                Section(header: Text("Hashflag")) {
                    HStack(spacing: 0) {
                        Spacer()
                        if let animation = firstTag.animations?.first, let url = animation.assetUrl {
                            WebImage(url: firstTag.assetUrl)
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
                            WebImage(url: firstTag.assetUrl)
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
                }
                Section(header: Text("Availabile")) {
                    Text("\(firstTag.startingTimestampMs, formatter: formatter) - \(firstTag.endingTimestampMs, formatter: formatter)")
                        .font(.headline)
                }
                Section(header: Text("Hashtags")) {
                    ForEach(tags) { tag in
                        Button(action: {
                            selectedHashtag = tag.hashtag
                        }) {
                            Text("#\(Text(tag.hashtag))")
                            .font(.headline)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text(firstTag.campaignName))
            .safariView(item: $selectedHashtag) {
                SafariView(url: URL(string: "https://twitter.com/hashtag/\($0)")!)
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var searchBar: SearchBar = SearchBar()
    @StateObject private var model: ViewModel = ViewModel()
    
    @State private var sortType: SortType = .latest
    @State var showSort = false
    @State var showSettings = false

    var items: [String]? {
        switch sortType {
        case .latest:
            return model.groupedLatestKeys
        case .endingSoon:
            return model.groupedEndingSoonKeys
        case .alphabetical:
            return model.groupedAlphabeticalKeys
        case .animated:
            return model.groupedAnimatedKeys

        }
    }
    
    var filteredItems: [String] {
        items?.filter {
            searchBar.text.isEmpty ? true : $0.lowercased().contains(searchBar.text.lowercased())
        } ?? []
    }

    @ViewBuilder func makeGridItem(tagKey: String) -> some View {
        NavigationLink(destination: DetailView(tagKey: tagKey).environmentObject(model)) {
            WebImage(url: model.groupedTags[tagKey]?.first?.assetUrl)
                .resizable()
                .indicator(.activity)
                .transition(.fade)
                .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder func makeTagView() -> some View {
        if let _ = items {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 88))]) {
                    ForEach(filteredItems, id: \.self) { tag in
                        makeGridItem(tagKey: tag)
                    }
                }
                .padding()
            }
        } else {
            Rectangle()
                .fill(Color.clear)
                .overlay(ProgressView())
        }
    }

    var body: some View {
        NavigationView {
            makeTagView()
                .navigationTitle("Hashflags")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            showSort.toggle()
                        }) {
                            Label("Sort", systemImage: "arrow.up.arrow.down.circle.fill")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        VStack {
                            Text("Sorted by:")
                            Text(sortType.rawValue.localizedCapitalized)
                        }
                        .font(.footnote)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                .add(self.searchBar)
            Text("Select a Hashflag")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .actionSheet(isPresented: $showSort) {
            ActionSheet(title: Text("Sorted by:"),
                        message: Text(sortType.rawValue.localizedCapitalized),
                        buttons: SortType.allCases.map { sort in
                            ActionSheet.Button.default(Text(sort.rawValue.localizedCapitalized), action: {
                                withAnimation {
                                    sortType = sort
                                }
                            })
                        } + [.cancel()]
            )
        }
        .sheet(isPresented: $showSettings) {
            Text("LOOKS ITS ME!")
        }
        .onAppear {
            model.fetch()
        }
    }
}

private let formatter: DateFormatter = {
   var formatter = DateFormatter()
   formatter.dateStyle = .short
   return formatter
}()
