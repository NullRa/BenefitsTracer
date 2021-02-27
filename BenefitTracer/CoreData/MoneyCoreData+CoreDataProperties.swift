//
//  MoneyCoreData+CoreDataProperties.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/28.
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
    @NSManaged public var belongto: UserCoreData?
    @NSManaged public var own: NSSet?

}

// MARK: Generated accessors for own
extension MoneyCoreData {

    @objc(addOwnObject:)
    @NSManaged public func addToOwn(_ value: BenefitsCoreData)

    @objc(removeOwnObject:)
    @NSManaged public func removeFromOwn(_ value: BenefitsCoreData)

    @objc(addOwn:)
    @NSManaged public func addToOwn(_ values: NSSet)

    @objc(removeOwn:)
    @NSManaged public func removeFromOwn(_ values: NSSet)

}

extension MoneyCoreData : Identifiable {

}
