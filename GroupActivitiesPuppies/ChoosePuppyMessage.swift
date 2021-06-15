//
//  ChoosePuppyMessage.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/12/21.
//

import Foundation

struct ChoosePuppyMessage: GroupActivityMessage {

    private(set) var id: UUID
    private(set) var timestamp: Date
    let puppyName: String

    init(id: UUID = UUID(), timestamp: Date = Date(), puppyName: String) {

        self.id = id
        self.timestamp = timestamp
        self.puppyName = puppyName
    }

    init?(payload: GroupActivityMessage) {

        guard let payload = payload as? Self else {

            return nil
        }

        self.init(puppyName: payload.puppyName)
    }
}
