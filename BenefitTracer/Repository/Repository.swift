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
    
    func resetCoreData(){
        deleteAllUserCoreData()
        deleteAllItemCoreData()
    }
    
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

    func updateBenefitsCoreData(benefits:Float,date:Date){
        do {
            let allMoneyCoreData = try viewContext.fetch(MoneyCoreData.fetchRequest())
            for moneyCoreData in allMoneyCoreData as! [MoneyCoreData] {
                if moneyCoreData.date == date {
                    let benefitsData = NSEntityDescription.insertNewObject(forEntityName: "BenefitsCoreData", into: viewContext) as! BenefitsCoreData
                    benefitsData.benefits = benefits
                    moneyCoreData.addToOwn(benefitsData)
                    app.saveContext()
                    return
                }
            }
        } catch {
            print(error)
        }
    }
    
    func insertMoneyCoreData(userName:String,money:Float,date:Date){
        do {
            let allUser = try viewContext.fetch(UserCoreData.fetchRequest())
            for user in allUser as! [UserCoreData] {
                if user.name == userName {
                    let moneyData = NSEntityDescription.insertNewObject(forEntityName: "MoneyCoreData", into: viewContext) as! MoneyCoreData
                    moneyData.price = money
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
                            if let benefitsCoreDatas = moneyData.own as? Set<BenefitsCoreData> {
                                benefitsCoreDatas.forEach { (benefitsCoreData) in
                                    viewContext.delete(benefitsCoreData)
                                }
                            }
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

    func queryMoneyCoreData(userName:String) -> [(Float,Date?,[Float])]{
        var moneyDatas = [(Float,Date?,[Float])]()
        
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        let predicate = NSPredicate(format: "name = '\(userName)'")
        fetchRequest.predicate = predicate
        do {
            let allUserCoreData = try viewContext.fetch(fetchRequest)
            for userCoreData in allUserCoreData {
                if userCoreData.own != nil {
                    for moneyCoreData in userCoreData.own as! Set<MoneyCoreData> {
                        var benefitsArray:[Float] = []
                        if moneyCoreData.own != nil {
                            for benefitsCoreData in moneyCoreData.own as! Set<BenefitsCoreData> {
                                benefitsArray.append(benefitsCoreData.benefits)
                            }
                        }
                        moneyDatas.append((moneyCoreData.price,moneyCoreData.date,benefitsArray))
                    }
                }
            }
            return moneyDatas
        } catch {
            print(error)
            return moneyDatas
        }
    }
    
    func deleteAllMoneyCoreData(userName:String) {
        deleteAllBenefitsCoreData()
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
    
    func deleteAllBenefitsCoreData() {
        do {
            let allBenefits = try viewContext.fetch(BenefitsCoreData.fetchRequest())
            for benefits in allBenefits as! [BenefitsCoreData] {
                viewContext.delete(benefits)
            }
            app.saveContext()
        } catch {
            print(error)
        }
    }
    
    func insertItemCoreData(name:String,price:Float){
        let newCoreDataItem = NSEntityDescription.insertNewObject(forEntityName: "ItemCoreData", into: viewContext) as! ItemCoreData
        newCoreDataItem.itemName = name
        newCoreDataItem.itemPrice = price
        newCoreDataItem.itemBenefits = 0
        app.saveContext()
    }
    
    func updateItemCoreData(name:String,newMoney:Float,newName:String?=nil,benefits:Float) {
        do {
            let allItemCoreData = try viewContext.fetch(ItemCoreData.fetchRequest())
            for itemCoreData in allItemCoreData as! [ItemCoreData] {
                if(itemCoreData.itemName! == name){
                    itemCoreData.itemPrice = newMoney
                    itemCoreData.itemBenefits = benefits
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
    
    func queryItemCoreData() -> [(String,Float,Float)] {
        var itemDatas = [(String,Float,Float)]()
        do {
            let allItemCoreData = try viewContext.fetch(ItemCoreData.fetchRequest())
            for itemCoreData in allItemCoreData as! [ItemCoreData] {
                let name = itemCoreData.itemName!
                let price = itemCoreData.itemPrice
                let benefits = itemCoreData.itemBenefits
                itemDatas.append((name,price,benefits))
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

