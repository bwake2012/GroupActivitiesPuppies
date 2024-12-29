//
//  ChoosePuppyMessage.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/12/21.
//

import Foundation

struct ChoosePuppyMessage: GroupActivityMessage, Codable {

    private(set) var id: UUID
    private(set) var timestamp: Date
    let fileName: String
    let title: String

    init(id: UUID = UUID(), timestamp: Date = Date(), fileName: String, title: String) {

        self.id = id
        self.timestamp = timestamp
        self.fileName = fileName
        self.title = title
    }

    init?(payload: GroupActivityMessage) {

        guard let payload = payload as? Self else {

            return nil
        }

        self.init(
            id: payload.id,
            timestamp: payload.timestamp,
            fileName: payload.fileName,
            title: payload.title)
    }
}
