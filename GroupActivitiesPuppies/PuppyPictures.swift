//
//  PuppyPictures.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/10/21.
//

import UIKit

class PuppyPictures {

    static let fileNames = ["AnnaAvatar", "AmericanEskimo", "Boo", "Buddy", "corgi", "Pontus", "SnowyTricolorSheltie"]

    var count: Int { return Self.fileNames.count }

    func puppyImage(_ index: Int) -> UIImage? {

        guard 0 <= index, index < count else { return nil }

        guard let url = Bundle.main.url(forResource: Self.fileNames[index], withExtension: "png")
        else {
            preconditionFailure("No URL for \(Self.fileNames[index])")
        }

        guard let data = try? Data(contentsOf: url, options: .uncachedRead)
        else {
            preconditionFailure("No data from \(Self.fileNames[index])")
        }

        guard let image = UIImage(data: data)
        else {
            preconditionFailure("Data from \(Self.fileNames[index]) is not an image.")
        }

        return image
    }
}
