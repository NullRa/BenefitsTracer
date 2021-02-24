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
    
    func queryUserCoreData() -> [String]{
        var userNameList = [String]()
        do {
            let allUserCoreData = try viewContext.fetch(UserCoreData.fetchRequest())
            for userCoreData in allUserCoreData as! [UserCoreData] {
                userNameList.append(userCoreData.name!)
            }
            return userNameList
        } catch {
            print(error)
            return userNameList
        }
    }
    func deleteUserCoreData(name:String){
        do{
            let all = try viewContext.fetch(UserCoreData.fetchRequest())
            for data in all as! [UserCoreData] {
                if data.name == name {
                    viewContext.delete(data)
                    app.saveContext()
                }
            }
        }catch{
            print(error)
        }
    }
    func insertMoneyCoreData(userName:String,money:Int,date:Date){
        do {
            let allUser = try viewContext.fetch(UserCoreData.fetchRequest())
            for user in allUser as! [UserCoreData] {
                if user.name == userName {
                    let moneyData = NSEntityDescription.insertNewObject(forEntityName: "MoneyCoreData", into: viewContext) as! MoneyCoreData
                    moneyData.price = Int32(money)
                    moneyData.date = date
                    user.addToOwn(moneyData)
                    app.saveContext()
                }
            }
        } catch {
            print(error)
        }
    }
    func deleteMoneyCoreData(userName:String,date:Date){
        do{
            let allUser = try viewContext.fetch(UserCoreData.fetchRequest())
            for user in allUser as! [UserCoreData] {
                if user.name == userName {
                    let allMoney = try viewContext.fetch(MoneyCoreData.fetchRequest())
                    for moneyData in allMoney as! [MoneyCoreData] {
                        if moneyData.date == date {
                            viewContext.delete(moneyData)
                            app.saveContext()
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
    }

    func queryMoneyCoreData(userName:String) -> [(String,Date?)]{
        var moneyDatas = [(String,Date?)]()
        
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        let predicate = NSPredicate(format: "name = '\(userName)'")
        fetchRequest.predicate = predicate
        do {
            let allUserCoreData = try viewContext.fetch(fetchRequest)
            for userCoreData in allUserCoreData {
                if userCoreData.own != nil {
                    for moneyCoreData in userCoreData.own as! Set<MoneyCoreData> {
                        moneyDatas.append(("\(moneyCoreData.price)",moneyCoreData.date))
                    }
                }
            }
            moneyDatas.append(("Add Money",nil))
            return moneyDatas
        } catch {
            print(error)
            return moneyDatas
        }
    }
    
    func insertItemCoreData(name:String,price:Int,id:Int){
        let newCoreDataItem = NSEntityDescription.insertNewObject(forEntityName: "ItemCoreData", into: viewContext) as! ItemCoreData
        newCoreDataItem.itemName = name
        newCoreDataItem.itemPrice = Int32(price)
        newCoreDataItem.itemID = Int32(id)
        app.saveContext()
    }

    func queryItemCoreData() -> [(String,Int)] {
        let fetchRequest: NSFetchRequest<ItemCoreData> = ItemCoreData.fetchRequest()
        let sort = NSSortDescriptor(key: "itemID", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        var itemDataDict = [(String,Int)]()
        do {
            let allItemCoreData = try viewContext.fetch(fetchRequest)
            for itemCoreData in allItemCoreData {
                print(itemCoreData.itemID)
                let name = itemCoreData.itemName!
                let price = itemCoreData.itemPrice
                itemDataDict.append((name,Int(price)))
            }
            return itemDataDict
        } catch {
            print(error)
            return itemDataDict
        }
    }

    func deleteItemCoreData(name:String){
        do {
            let allItemCoreData = try viewContext.fetch(ItemCoreData.fetchRequest())
            for data in allItemCoreData as! [ItemCoreData] {
                if data.itemName == name {
                    viewContext.delete(data)
                    app.saveContext()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func deleteAllItemCoreData(){
        do {
            let allItemCoreData = try viewContext.fetch(ItemCoreData.fetchRequest())
            for data in allItemCoreData as! [ItemCoreData] {
                viewContext.delete(data)
            }
            app.saveContext()
        } catch {
            print(error)
        }
    }
}

