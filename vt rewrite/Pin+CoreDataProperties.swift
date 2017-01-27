//
//  Pin+CoreDataProperties.swift
//  vt rewrite
//
//  Created by Harry Merzin on 1/26/17.
//  Copyright © 2017 Harry Merzin. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Pin: NSFetchRequestResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var latitude: Int32
    @NSManaged public var longitude: Int32
    @NSManaged public var imagesCount: Double
    @NSManaged public var image: NSSet?

}

// MARK: Generated accessors for image
extension Pin {

    @objc(addImageObject:)
    @NSManaged public func addToImage(_ value: Image)

    @objc(removeImageObject:)
    @NSManaged public func removeFromImage(_ value: Image)

    @objc(addImage:)
    @NSManaged public func addToImage(_ values: NSSet)

    @objc(removeImage:)
    @NSManaged public func removeFromImage(_ values: NSSet)

}
