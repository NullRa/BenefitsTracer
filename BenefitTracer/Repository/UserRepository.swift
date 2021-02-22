//
//  UserRepository.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//

import Foundation
import CoreData
import UIKit

class UserRespository {
    let app = UIApplication.shared.delegate as! AppDelegate
    var viewContext: NSManagedObjectContext! = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func insertUserCoreData(name:String) {
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "UserCoreData", into: viewContext) as! UserCoreData
        newUser.name = name
        app.saveContext()
    }
    
    func queryUserCoreData() -> [UserData]{
        var userDatas = [UserData]()
        do {
            let all = try viewContext.fetch(UserCoreData.fetchRequest())
            for data in all as! [UserCoreData] {
                userDatas.append(UserData(userName: data.name!))
            }
            return userDatas
        } catch {
            print(error)
            return userDatas
        }
    }
    func deleteUserCoreData(name:String){
        do{
            let all = try viewContext.fetch(UserCoreData.fetchRequest())
            for data in all as! [UserCoreData] {
                if data.name == name {
                    viewContext.delete(data)
                }
            }
            app.saveContext()
        }catch{
            print(error)
        }
    }
}

