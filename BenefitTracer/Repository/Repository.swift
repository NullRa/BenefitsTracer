//
//  UserRepository.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//

import Foundation
import CoreData
import UIKit

class Respository {
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
    func deleteAllUserCoreData(){
        do{
            let all = try viewContext.fetch(UserCoreData.fetchRequest())
            for data in all as! [UserCoreData] {
                deleteAllMoneyCoreData(userName: data.name!)
                viewContext.delete(data)
            }
            app.saveContext()
        }catch{
            print(error)
        }
    }
    func resetCoreData(){
        deleteAllUserCoreData()
        deleteAllItemCoreData()
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
    
    func deleteAllMoneyCoreData(userName:String) {
        do{
            let allUser = try viewContext.fetch(UserCoreData.fetchRequest())
            for user in allUser as! [UserCoreData] {
                if user.name == userName {
                    let allMoney = try viewContext.fetch(MoneyCoreData.fetchRequest())
                    for moneyData in allMoney as! [MoneyCoreData] {
                        viewContext.delete(moneyData)
                    }
                    app.saveContext()
                }
            }
        }catch{
            print(error)
        }
    }
    
    func insertItemCoreData(name:String,price:Int){
        let newCoreDataItem = NSEntityDescription.insertNewObject(forEntityName: "ItemCoreData", into: viewContext) as! ItemCoreData
        newCoreDataItem.itemName = name
        newCoreDataItem.itemPrice = Int32(price)
        newCoreDataItem.itemBenefits = 0
        app.saveContext()
    }
    
    func updateItemCoreData(name:String,newMoney:Int,newName:String?=nil,benefits:Int) {
        do {
            let allItemCoreData = try viewContext.fetch(ItemCoreData.fetchRequest())
            for itemCoreData in allItemCoreData as! [ItemCoreData] {
                if(itemCoreData.itemName! == name){
                    itemCoreData.itemPrice = Int32(newMoney)
                    if newName != nil {
                        itemCoreData.itemName = newName
                    }
                    app.saveContext()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func queryItemCoreData() -> [(String,Int,Int)] {
        var itemDatas = [(String,Int,Int)]()
        do {
            let allItemCoreData = try viewContext.fetch(ItemCoreData.fetchRequest())
            for itemCoreData in allItemCoreData as! [ItemCoreData] {
                let name = itemCoreData.itemName!
                let price = itemCoreData.itemPrice
                let benefits = itemCoreData.itemBenefits
                itemDatas.append((name,Int(price),Int(benefits)))
            }
            return itemDatas
        } catch {
            print(error)
            return itemDatas
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

