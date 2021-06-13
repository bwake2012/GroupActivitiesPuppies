//
//  ChoosePuppyActivity.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/10/21.
//

import GroupActivities
import UIKit

struct ChoosePuppyActivity: GroupActivity {

    // specify the activity type to the system
    static let activityIdentifier = "net.cockleburr.sample.choose-puppy"

    // provide information about the activity
    var metadata: GroupActivityMetadata {

        var metadata = GroupActivityMetadata()

        metadata.type = .generic
        metadata.title = NSLocalizedString("Choose Puppy by Bob Wakefield", comment: "")
        metadata.subtitle = NSLocalizedString("Transmits and receives names of puppy picture files for display.", comment: "")

        return metadata
    }
}

