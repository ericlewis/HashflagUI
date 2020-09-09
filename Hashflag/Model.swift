//
//  Model.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/8/20.
//

import SwiftUI
import Combine

extension String: Identifiable {
    public var id: Self {
        self
    }
}

struct Tag: Decodable, Identifiable {
    let id: UUID
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
        
        id = UUID() // booo
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

enum SortType: String, CaseIterable {
    case latest
    case endingSoon = "ending soon"
    case alphabetical
    case animated
}

class ViewModel: ObservableObject {
    private var url: URL? {
        return URL(string: "https://pbs.twimg.com/hashflag/config-2020-09-08.json")
    }
    
    @Published var groupedTags: [String: [Tag]] = [:]
    
    @Published var groupedAlphabeticalKeys: [String]?
    @Published var groupedLatestKeys: [String]?
    @Published var groupedEndingSoonKeys: [String]?
    @Published var groupedAnimatedKeys: [String]?

    private var cancellable: AnyCancellable?
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
    
    func fetch() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url!)
            .map { $0.data }
            .decode(type: [Tag].self, decoder: decoder)
            .receive(on: RunLoop.main)
            .sink { completion in
                print(completion)
            } receiveValue: { [weak self] tags in
                self?.groupedTags = Dictionary(grouping: tags.filter { $0.endingTimestampMs > Date() }, by: { $0.campaignName })
                
                self?.groupedAlphabeticalKeys = self?.groupedTags.keys.sorted() ?? []
                self?.groupedLatestKeys = self?.groupedTags.keys.sorted {
                    self?.groupedTags[$0]?.first?.startingTimestampMs ?? Date() > self?.groupedTags[$1]?.first?.startingTimestampMs ?? Date()
                } ?? []
                
                self?.groupedEndingSoonKeys = self?.groupedTags.keys.sorted {
                    self?.groupedTags[$0]?.first?.endingTimestampMs ?? Date() < self?.groupedTags[$1]?.first?.endingTimestampMs ?? Date()
                } ?? []
                
                self?.groupedAnimatedKeys = self?.groupedTags.keys.filter {
                    self?.groupedTags[$0]?.contains {
                        $0.animations != nil
                    } ?? false
                }
            }
    }
}
