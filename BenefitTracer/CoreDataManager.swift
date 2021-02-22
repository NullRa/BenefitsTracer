//
//  CoreDataManager.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    let app = UIApplication.shared.delegate as! AppDelegate
    var viewContext: NSManagedObjectContext! = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //MARK:- init
//    class var sharedInstance : CoreDataManager {
//        struct Static {
//            static let sharedInstance = CoreDataManager()
//        }
//        return Static.sharedInstance
//    }
    
    func insertUserData() {
        var test1 = NSEntityDescription.insertNewObject(forEntityName: "UserCoreData", into: viewContext) as! UserCoreData
        test1.name = "test1"
        test1 = NSEntityDescription.insertNewObject(forEntityName: "UserCoreData", into: viewContext) as! UserCoreData
        test1.name = "test3"
        app.saveContext()
    }
    func queryUserCoreData(){
        do {
            let all = try viewContext.fetch(UserCoreData.fetchRequest())
            for data in all as! [UserCoreData] {
                print("\(data.name)")
            }
        } catch {
            print(error)
        }
    }
    func deleteUserData_Onebyone(){
        do{
            let all = try viewContext.fetch(UserCoreData.fetchRequest())
            for data in all as! [UserCoreData] {
                viewContext.delete(data)
            }
            app.saveContext()
        }catch{
            print(error)
        }
    }
}
