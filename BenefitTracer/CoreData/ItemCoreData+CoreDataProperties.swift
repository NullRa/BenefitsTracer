//
//  ItemCoreData+CoreDataProperties.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/26.
//
//

import Foundation
import CoreData


extension ItemCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemCoreData> {
        return NSFetchRequest<ItemCoreData>(entityName: "ItemCoreData")
    }

    @NSManaged public var itemName: String?
    @NSManaged public var itemPrice: Int32
    @NSManaged public var itemBenefits: Int32

}

extension ItemCoreData : Identifiable {

}
