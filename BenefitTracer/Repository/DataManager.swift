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
    var name:String
    var money:Int
    var benefits: Int = 0
    var benefitsString:String {
        if benefits >= 0 {
            return "+\(benefits)%"
        } else {
            return "\(benefits)%"
        }
    }
    func getMoneyWithBenefits() -> Int{
        return (money + money*benefits/100)
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
    func resetCoreData(){
        respository.resetCoreData()
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
        if money > itemDataList[0].money {
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
        let itemThreeWayData = respository.queryItemCoreData()
        for (name,price,benefits) in itemThreeWayData {
            let itemData = ItemData(name: name, money: price, benefits: benefits)
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
            totalMoney = totalMoney + itemData.money
        }
        return totalMoney
    }
    
    func addItemIsSuccessful(itemName:String, money:Int) -> Bool {
        if itemDataList.isEmpty {
            itemDataList.append(ItemData(name: itemName, money: money))
            respository.insertItemCoreData(name: itemName, price: money)
        } else {
            let unHandleMoney = itemDataList[0].getMoneyWithBenefits()
            let newUnHandleMoney = unHandleMoney - money
            if money > unHandleMoney {
                return false
            }
            itemDataList[0].money = newUnHandleMoney
            respository.updateItemCoreData(name: itemDataList[0].name, newMoney: newUnHandleMoney, benefits: 0)
            itemDataList.append(ItemData(name: itemName, money: money))
            respository.insertItemCoreData(name: itemName, price: money)
        }
        return true
    }
    
    func removeItem(itemID:Int){
        let deleteItem = itemDataList.remove(at: itemID)
        itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() + deleteItem.getMoneyWithBenefits()
        respository.updateItemCoreData(name: itemDataList[0].name, newMoney: itemDataList[0].money, benefits: 0)
        respository.deleteItemCoreData(name: deleteItem.name)
    }
    
    func editItemIsSuccessful(itemID:Int,newName:String,newPrice:Int) -> Bool {
        if itemID == 0 {
            //FIXME
            assertionFailure("ERROR ITEM0")
        }
        let oldPrice = itemDataList[itemID].getMoneyWithBenefits()
        let oldName = itemDataList[itemID].name
        if newPrice > itemDataList[0].getMoneyWithBenefits() + oldPrice {
            return false
        }
        if oldPrice > newPrice {
            itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() + (oldPrice - newPrice)
        } else {
            itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() - (newPrice - oldPrice)
        }
        itemDataList[itemID].money = newPrice
        itemDataList[itemID].name = newName
        respository.updateItemCoreData(name: oldName, newMoney: newPrice, newName: newName, benefits: 0)
        return true
    }
    
    func addExtraMoneyIsSuccessful(itemID:Int,extraPrice:Int) -> Bool {
        if itemID == 0 {
            //FIXME
            assertionFailure("ERROR ITEM0")
        }
        if extraPrice > itemDataList[0].getMoneyWithBenefits() {
            return false
        }
        itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() - extraPrice
        respository.updateItemCoreData(name: itemDataList[0].name, newMoney: itemDataList[0].money, benefits: 0)
        itemDataList[itemID].money = itemDataList[itemID].getMoneyWithBenefits() + extraPrice
        respository.updateItemCoreData(name: itemDataList[itemID].name, newMoney: itemDataList[itemID].money, benefits: 0)
        return true
    }
    
    func editUnHandleMoney(extraPrice:Int){
        itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() + extraPrice
        respository.updateItemCoreData(name: itemDataList[0].name, newMoney: itemDataList[0].money, benefits: 0)
    }
    
    // MARK: - BenefitsView
    func getListItem(itemIndex: Int) -> (String,String,String){
        //name,price,benefits
        let name = itemDataList[itemIndex].name
        let money = "\(itemDataList[itemIndex].money)"
        let benefits = "\(itemDataList[itemIndex].benefits)"
        return (name,money,benefits)
    }
    
    func getListItem2(itemIndex: Int) -> ItemData {
        return itemDataList[itemIndex]
    }
    
    func addBenefits(benefitsMoney:Int, itemIndex:Int){
        //FIXME被除數等於零
        itemDataList[itemIndex].benefits = benefitsMoney * 100 / itemDataList[itemIndex].money
        itemDataList[itemIndex].money = itemDataList[itemIndex].money + benefitsMoney
        respository.updateItemCoreData(name: itemDataList[itemIndex].name, newMoney: itemDataList[itemIndex].money, benefits: itemDataList[itemIndex].benefits)
        
    }
}
