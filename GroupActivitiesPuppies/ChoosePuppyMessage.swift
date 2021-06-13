//
//  ChoosePuppyMessage.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/12/21.
//

import Foundation

struct ChoosePuppyMessage: Codable {

    let id: UUID
    let timestamp: Date
    let puppyName: String

    init(id: UUID = UUID(), timestamp: Date = Date(), puppyName: String) {

        self.id = id
        self.timestamp = timestamp
        self.puppyName = puppyName
    }
}
