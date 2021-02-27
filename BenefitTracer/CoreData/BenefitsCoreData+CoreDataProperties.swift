//
//  BenefitsCoreData+CoreDataProperties.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/28.
//
//

import Foundation
import CoreData


extension BenefitsCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BenefitsCoreData> {
        return NSFetchRequest<BenefitsCoreData>(entityName: "BenefitsCoreData")
    }

    @NSManaged public var benefits: Float
    @NSManaged public var belongto: MoneyCoreData?

}

extension BenefitsCoreData : Identifiable {

}
