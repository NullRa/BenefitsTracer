//
//  DataManager.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/25.
//

import Foundation

struct MoneyData {
    var moneyString: String
    var date: Date?
}
struct UserData {
    var isOpen:Bool = false
    var money = [MoneyData]()
    var userName:String

    func getUserTotalMoney() -> Int {
        var totalMoney = 0
        money.forEach { (moneyData) in
            if moneyData.moneyString != "Add Money" {
                totalMoney = totalMoney + Int(moneyData.moneyString)!
            }
        }
        return totalMoney
    }
}

struct ItemData {
    var itemName:String
    var itemPrice:Int
}
struct ItemDataWithBenefits {
    var itemData: ItemData
    var benefits: Int
    var benefitsString:String {
        if benefits >= 0 {
            return "+\(benefits)%"
        } else {
            return "\(benefits)%"
        }
    }
}
class DataManager {
    static let shared = DataManager()
    let respository = Respository()
    var userDataList = [UserData]()
    var itemDataList = [ItemData]()

    init() {
        setUserViewModelList()
        setItemViewModelList()
    }

    // MARK: - UserView
    private func setUserViewModelList(){
        let userNameList = respository.queryUserCoreData()
        userNameList.forEach { (userName) in
            let userMoneyDatas = respository.queryMoneyCoreData(userName: userName)
            var moneyDatas = [MoneyData]()
            userMoneyDatas.forEach { (moneyString, addMoneyDate) in
                moneyDatas.append(MoneyData(moneyString: moneyString, date: addMoneyDate))
            }
            userDataList.append(UserData(isOpen: false, money: moneyDatas, userName: userName))
        }
    }

    func addUser(userName:String) {
        userDataList.append(UserData(money: [MoneyData(moneyString: "Add Money", date: nil)], userName: userName))
        respository.insertUserCoreData(name: userName)
    }

    func removeUser(userIndex:Int) {
        let name = userDataList[userIndex].userName
        userDataList.remove(at: userIndex)
        respository.deleteUserCoreData(name: name)
    }

    func addMoney(userIndex:Int,money:String){
        let date = Date()
        userDataList[userIndex].money.insert(MoneyData(moneyString: money, date: date), at: userDataList[userIndex].money.count-1)
        let username = userDataList[userIndex].userName
        let moneyPrice = Int(money)!
        respository.insertMoneyCoreData(userName: username, money: moneyPrice, date: date)
    }

    func removeMoneyResult(userIndex:Int,moneyIndex:Int) -> Bool {
        guard let moneyDate = userDataList[userIndex].money[moneyIndex].date else {
            assertionFailure("ERROR")
            return false
        }
        let name = userDataList[userIndex].userName
        let money = Int(userDataList[userIndex].money[moneyIndex].moneyString)!
        if money > itemDataList[0].itemPrice {
            return false
        }
        userDataList[userIndex].money.remove(at: moneyIndex)
        respository.deleteMoneyCoreData(userName: name, date: moneyDate)
        return true
    }

    func getTotalMoneyByUserData() -> Int {
        var totalMoney: Int = 0
        userDataList.forEach { (userData) in
            userData.money.forEach { (moneyData) in
                if let moneyPrice = Int(moneyData.moneyString)  {
                    totalMoney = totalMoney + moneyPrice
                }
            }
        }
        return totalMoney
    }
    
    // MARK: - ItemView
    private func setItemViewModelList(){
        let itemTwoWayData = respository.queryItemCoreData()
        for (name,price) in itemTwoWayData {
            let itemData = ItemData(itemName: name, itemPrice: price)
            itemDataList.append(itemData)
        }
        if itemDataList.isEmpty {
            let totalMoney = getTotalMoneyByUserData()
            let _ = addItemIsSuccessful(itemName: "UnHandle", money: totalMoney)
        }
    }
    
    func getTotalMoneyByItemData() -> Int {
        var totalMoney: Int = 0
        itemDataList.forEach { (itemData) in
            totalMoney = totalMoney + itemData.itemPrice
        }
        return totalMoney
    }
    
    func addItemIsSuccessful(itemName:String, money:Int) -> Bool {
        if itemDataList.isEmpty {
            itemDataList.append(ItemData(itemName: itemName, itemPrice: money))
            respository.insertItemCoreData(name: itemName, price: money)
        } else {
            let unHandleMoney = itemDataList[0].itemPrice
            let newUnHandleMoney = unHandleMoney - money
            if money > unHandleMoney {
                return false
            }
            itemDataList[0].itemPrice = newUnHandleMoney
            respository.updateItemCoreData(name: itemDataList[0].itemName, newMoney: newUnHandleMoney)
            itemDataList.append(ItemData(itemName: itemName, itemPrice: money))
            respository.insertItemCoreData(name: itemName, price: money)
        }
        return true
    }
    
    func removeItem(itemID:Int){
        let deleteItem = itemDataList.remove(at: itemID)
        itemDataList[0].itemPrice = itemDataList[0].itemPrice + deleteItem.itemPrice
        respository.updateItemCoreData(name: itemDataList[0].itemName, newMoney: itemDataList[0].itemPrice)
        respository.deleteItemCoreData(name: deleteItem.itemName)
    }
    
    func editItemIsSuccessful(itemID:Int,newName:String,newPrice:Int) -> Bool {
        if itemID == 0 {
            //FIXME
            assertionFailure("ERROR ITEM0")
        }
        let oldPrice = itemDataList[itemID].itemPrice
        let oldName = itemDataList[itemID].itemName
        if newPrice > itemDataList[0].itemPrice + oldPrice {
            return false
        }
        if oldPrice > newPrice {
            itemDataList[0].itemPrice = itemDataList[0].itemPrice + (oldPrice - newPrice)
        } else {
            itemDataList[0].itemPrice = itemDataList[0].itemPrice - (newPrice - oldPrice)
        }
        itemDataList[itemID].itemPrice = newPrice
        itemDataList[itemID].itemName = newName
        respository.updateItemCoreData(name: oldName, newMoney: newPrice, newName: newName)
        return true
    }
    
    func addExtraMoneyIsSuccessful(itemID:Int,extraPrice:Int) -> Bool {
        if itemID == 0 {
            //FIXME
            assertionFailure("ERROR ITEM0")
        }
        if extraPrice > itemDataList[0].itemPrice {
            return false
        }
        itemDataList[0].itemPrice = itemDataList[0].itemPrice - extraPrice
        respository.updateItemCoreData(name: itemDataList[0].itemName, newMoney: itemDataList[0].itemPrice)
        itemDataList[itemID].itemPrice = itemDataList[itemID].itemPrice + extraPrice
        respository.updateItemCoreData(name: itemDataList[itemID].itemName, newMoney: itemDataList[itemID].itemPrice)
        return true
    }
    
    func editUnHandleMoney(extraPrice:Int){
        itemDataList[0].itemPrice = itemDataList[0].itemPrice + extraPrice
        respository.updateItemCoreData(name: itemDataList[0].itemName, newMoney: itemDataList[0].itemPrice)
    }
}
