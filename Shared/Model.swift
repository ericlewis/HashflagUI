//
//  Model.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/8/20.
//

import SwiftUI
import Combine
import CoreData

struct FetchRequests {
    private static func current() -> NSFetchRequest<Campaign> {
        let request: NSFetchRequest<Campaign> = Campaign.fetchRequest()
        request.predicate = NSPredicate(format: "endDate >= %@", NSDate())
        return request
    }
    
    static func alphabetical() -> NSFetchRequest<Campaign> {
        let request = Self.current()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    static func latest() -> NSFetchRequest<Campaign> {
        let request = Self.current()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        return request
    }
    
    static func endingSoon() -> NSFetchRequest<Campaign> {
        let request = Self.current()
        request.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        return request
    }
}

extension String: Identifiable {
    public var id: Self {
        self
    }
}

struct Hashflag: Decodable {
    
    let campaignName: String
    let hashtag: String
    let assetUrl: URL
    let startingTimestampMs: Date
    let endingTimestampMs: Date
    let animations: [TagAnimation]?
    
    enum CodingKeys: String, CodingKey {
        case campaignName
        case hashtag
        case assetURL = "assetUrl"
        case startingTimestampMS = "startingTimestampMs"
        case endingTimestampMS = "endingTimestampMs"
        case animations
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        campaignName = try values.decode(String.self, forKey: .campaignName)
        hashtag = try values.decode(String.self, forKey: .hashtag)
        assetUrl = try values.decode(URL.self, forKey: .assetURL)
        
        if values.contains(.animations) {
            animations = try values.decode([TagAnimation].self, forKey: .animations)
        } else {
            animations = nil
        }

        let startingTimestampMsString = try values.decode(String.self, forKey: .startingTimestampMS)
        startingTimestampMs = Date(timeIntervalSince1970: (Double(startingTimestampMsString) ?? 0) / 1000)
        
        let endingTimestampMsString = try values.decode(String.self, forKey: .endingTimestampMS)
        endingTimestampMs = Date(timeIntervalSince1970: (Double(endingTimestampMsString) ?? 0) / 1000)
    }
}

struct TagAnimation: Decodable {
    let context: String
    let assetUrl: URL
}

class API {
    private let url: URL? = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return URL(string: "https://pbs.twimg.com/hashflag/config-\(dateFormatter.string(from: Date())).json")
    }()
    
    private var cancellable: AnyCancellable?
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
    
    init() {
        fetch()
    }
    
    func fetch(context: NSManagedObjectContext = PersistenceController.shared.container.newBackgroundContext()) {
        context.perform { [weak self] in
            self?.cancellable =
                self?.fetchPublisher(context: context)
                .sink { completion in
                    do {
                        try context.save()
                    } catch {
                        print(error)
                    }
                } receiveValue: { tags in
                    tags.forEach {
                        let request: NSFetchRequest<Campaign> = Campaign.fetchRequest()
                        request.predicate = NSPredicate(format: "name = %@", $0.campaignName)
                        let result = try? context.fetch(request)
                        
                        let campaign = result?.first ?? Campaign(context: context)
                        
                        campaign.imageURL = $0.assetUrl
                        campaign.name = $0.campaignName
                        campaign.startDate = $0.startingTimestampMs
                        campaign.endDate = $0.endingTimestampMs
                        
                        let requestHashtag: NSFetchRequest<Hashtag> = Hashtag.fetchRequest()
                        requestHashtag.predicate = NSPredicate(format: "value = %@", $0.hashtag)
                        let resultHashtag = try? context.fetch(requestHashtag)
                        let hashtag = resultHashtag?.first ?? Hashtag(context: context)
                        hashtag.value = $0.hashtag
                        hashtag.campaign = campaign
                        
                        $0.animations?.forEach {
                            let requestAnimations: NSFetchRequest<Animated> = Animated.fetchRequest()
                            requestAnimations.predicate = NSPredicate(format: "urlString = %@", $0.assetUrl.absoluteString)
                            let resultAnimations = try? context.fetch(requestAnimations)
                            let animation = resultAnimations?.first ?? Animated(context: context)
                            animation.url = $0.assetUrl
                            animation.urlString = $0.assetUrl.absoluteString
                            animation.type = $0.context
                            animation.campaign = campaign
                        }
                    }
                }
        }
    }
    
    private func fetchPublisher(context: NSManagedObjectContext) -> AnyPublisher<[Hashflag], Error> {
        return URLSession.shared.dataTaskPublisher(for: url!)
            .map { $0.data }
            .decode(type: [Hashflag].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
