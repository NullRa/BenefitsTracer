//
//  MoneyCoreData+CoreDataProperties.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/27.
//
//

import Foundation
import CoreData


extension MoneyCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoneyCoreData> {
        return NSFetchRequest<MoneyCoreData>(entityName: "MoneyCoreData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var price: Float
    @NSManaged public var benefits: Int32
    @NSManaged public var belongto: UserCoreData?

}

extension MoneyCoreData : Identifiable {

}
