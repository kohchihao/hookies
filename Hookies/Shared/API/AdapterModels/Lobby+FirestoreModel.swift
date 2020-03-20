//
//  Lobby+FirestoreModel.swift
//  Hookies
//
//  Created by Jun Wei Koh on 20/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

extension Lobby: FirestoreModel {
    var documentID: String {
        return lobbyId
    }

    var serialized: [String: Any?] {
        return defaultSerializer()
    }

    init?(modelData: FirestoreDataModel) {
        var selectedMap: MapType?
        if let mapString: String = modelData.optionalValue(forKey: "selectedMapType") {
            selectedMap = MapType(rawValue: mapString)
        }
        do {
            let costumesId: [String: String] = try modelData.value(forKey: "costumesId")
            let costumes = costumesId.compactMapValues({ CostumeType(rawValue: $0) })
            try self.init(
                lobbyId: modelData.documentID,
                hostId: modelData.value(forKey: "hostId"),
                lobbyState: modelData.value(forKey: "lobbyState"),
                selectedMapType: selectedMap,
                playersId: modelData.value(forKey: "playersId"),
                costumesId: costumes
            )
        } catch {
            return nil
        }
    }
}
