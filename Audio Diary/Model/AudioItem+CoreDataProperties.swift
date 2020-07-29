//
//  AudioItem+CoreDataProperties.swift
//  AudioDiary
//
//  Created by Romeno Wenogk Fernando on 29/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//
//

import Foundation
import CoreData


extension AudioItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioItem> {
        return NSFetchRequest<AudioItem>(entityName: "AudioItem")
    }

    @NSManaged public var audioFilePath: URL?
    @NSManaged public var dateTime: Date?
    @NSManaged public var transcribed: String?
    @NSManaged public var positiveProbability: Double
    @NSManaged public var negativeProbability: Double

}
