//
//  StickerBrowserViewController.swift
//  Hashflag Stickers MessagesExtension
//
//  Created by Eric Lewis on 9/8/20.
//

import UIKit
import Messages
import Combine
import SDWebImageSwiftUI

class StickerBrowserViewController: MSStickerBrowserViewController {

    var stickers = [MSSticker]()
    
    let cache = SDImageCache(namespace: "Hashflag",
                             diskCacheDirectory: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.hashflag")?.path)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStickers()
    }
    
    override var stickerSize: MSStickerSize {
        .small
    }
        
    var cancellable: AnyCancellable?
    
    func loadStickers() {
        let result = try? PersistenceController.shared.container.viewContext.fetch(FetchRequests.alphabetical())
        result?.forEach {
            createSticker(assetLocation: $0.imageURL!, assetDescription: "idk")
        }
    }

    func createSticker(assetLocation: URL, assetDescription: String) {
        do {
            let key = assetLocation.absoluteString.replacingOccurrences(of: ".png",
                                                                        with: "-SDImageResizingTransformer(%7B300.000000,300.000000%7D,0).png")
            if cache.diskImageDataExists(withKey: key) {
                let p = cache.cachePath(forKey: key)
                let url = URL(string: "file://\(p!)")!
                
                let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: assetDescription)
                stickers.append(sticker)
            } else {
                // cache miss, collect for later
                print("Cache miss: \(key)")
            }
        } catch {
            print(error)
        }
    }
}

extension StickerBrowserViewController {
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }

    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
}
