//
//  ItemCoreData+CoreDataProperties.swift
//  BenefitTracer
//
//  Created by Apple on 2021/3/2.
//
//

import Foundation
import CoreData


extension ItemCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemCoreData> {
        return NSFetchRequest<ItemCoreData>(entityName: "ItemCoreData")
    }

    @NSManaged public var itemBenefits: Float
    @NSManaged public var itemName: String?
    @NSManaged public var itemPrice: Float

}

extension ItemCoreData : Identifiable {

}
