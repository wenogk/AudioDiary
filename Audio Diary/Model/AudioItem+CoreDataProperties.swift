//
//  AudioItem+CoreDataProperties.swift
//  AudioDiary
//
//  Created by Romeno Wenogk Fernando on 30/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//
//

import Foundation
import CoreData


extension AudioItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioItem> {
        return NSFetchRequest<AudioItem>(entityName: "AudioItem")
    }

    @NSManaged public var audioFileName: String?
    @NSManaged public var dateTime: Date?
    @NSManaged public var negativeProbability: Double
    @NSManaged public var positiveProbability: Double
    @NSManaged public var transcribed: String?

}
