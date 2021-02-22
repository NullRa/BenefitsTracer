//
//  UserCoreData+CoreDataProperties.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//
//

import Foundation
import CoreData


extension UserCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCoreData> {
        return NSFetchRequest<UserCoreData>(entityName: "UserCoreData")
    }

    @NSManaged public var name: String?
    @NSManaged public var own: NSSet?

}

// MARK: Generated accessors for own
extension UserCoreData {

    @objc(addOwnObject:)
    @NSManaged public func addToOwn(_ value: MoneyCoreData)

    @objc(removeOwnObject:)
    @NSManaged public func removeFromOwn(_ value: MoneyCoreData)

    @objc(addOwn:)
    @NSManaged public func addToOwn(_ values: NSSet)

    @objc(removeOwn:)
    @NSManaged public func removeFromOwn(_ values: NSSet)

}

extension UserCoreData : Identifiable {

}
