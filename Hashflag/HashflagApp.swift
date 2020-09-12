//
//  HashflagApp.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/8/20.
//

import SwiftUI
import SDWebImage

let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.hashflag")?.path
let cache = SDImageCache(namespace: "Hashflag",
                         diskCacheDirectory: path)

@main
struct HashflagApp: App {
    private let api = API()
    private let persistenceController = PersistenceController.shared

    init() {
        SDImageCachesManager.shared.addCache(cache)
        SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
        SDWebImageManager.shared.transformer = SDImageResizingTransformer(size: CGSize(width: 300, height: 300),
                                                                          scaleMode: .fill)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
