//
//  MoneyCoreData+CoreDataProperties.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//
//

import Foundation
import CoreData


extension MoneyCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoneyCoreData> {
        return NSFetchRequest<MoneyCoreData>(entityName: "MoneyCoreData")
    }

    @NSManaged public var price: Int32
    @NSManaged public var date: Date?
    @NSManaged public var belongto: UserCoreData?

}

extension MoneyCoreData : Identifiable {

}
