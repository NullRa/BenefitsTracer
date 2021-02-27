//
//  DataManager.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/25.
//

import Foundation

struct MoneyData {
    var moneyPrice: Float
    var date: Date?
    var benefits: Int?
}
//FIXME
struct UserData {
    var isOpen:Bool = false
    var money:[MoneyData] = []
    var userName:String
    var totalMoney: Int{
        var totalMoney = 0
        money.forEach {
            (moneyData) in
            totalMoney = totalMoney + Int(moneyData.moneyPrice)
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
            userMoneyDatas.forEach { (moneyString, addMoneyDate, benefits) in
                moneyDatas.append(MoneyData(moneyPrice: moneyString, date: addMoneyDate, benefits: benefits))
            }
            userDataList.append(UserData(isOpen: false, money: moneyDatas, userName: userName))
        }
    }

    func addUser(userName:String) {
        userDataList.append(UserData(money: [], userName: userName))
        respository.insertUserCoreData(name: userName)
    }

    func removeUser(userIndex:Int) {
        let name = userDataList[userIndex].userName
        userDataList.remove(at: userIndex)
        respository.deleteUserCoreData(name: name)
    }

    func addMoney(userIndex:Int,money:Float){
        let date = Date()
        userDataList[userIndex].money.append(MoneyData(moneyPrice: money, date: date, benefits: 0))
        let username = userDataList[userIndex].userName
        let moneyPrice = money
        respository.insertMoneyCoreData(userName: username, money: moneyPrice, date: date)
        editUnHandleMoney(extraPrice: Int(money))
    }

    func removeMoneyResult(userIndex:Int,moneyIndex:Int) -> Bool {
        guard let moneyDate = userDataList[userIndex].money[moneyIndex].date else {
            assertionFailure("ERROR")
            return false
        }
        let name = userDataList[userIndex].userName
        let money = userDataList[userIndex].money[moneyIndex].moneyPrice
        if Int(money) > itemDataList[0].money {
            return false
        }
        userDataList[userIndex].money.remove(at: moneyIndex)
        respository.deleteMoneyCoreData(userName: name, date: moneyDate)
        return true
    }

    func getTotalMoneyByUserData() -> Int {
        var totalMoney: Int = 0
        userDataList.forEach { (userData) in
            totalMoney = totalMoney + userData.totalMoney
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
    
    func getListItem(itemIndex: Int) -> ItemData {
        return itemDataList[itemIndex]
    }
    
    func addBenefits(benefitsMoney:Int, itemIndex:Int){
        //FIXME被除數等於零
        itemDataList[itemIndex].benefits = benefitsMoney * 100 / itemDataList[itemIndex].money
        respository.updateItemCoreData(name: itemDataList[itemIndex].name, newMoney: itemDataList[itemIndex].money, benefits: itemDataList[itemIndex].benefits)

        //FIXME算出user每一筆user.money的benefits並紀錄
        //money [benefits]
        
    }

    //FIXME
    func getTotalBenefits() -> Int{
        var itemBenefitsMoney = 0
        var userOriginalMoney = 0
        var benefitsPresent = 0
        itemDataList.forEach { (itemData) in
            itemBenefitsMoney = itemBenefitsMoney + itemData.getMoneyWithBenefits()
        }
        userDataList.forEach { (userData) in
            userOriginalMoney = userOriginalMoney + userData.totalMoney
        }
        benefitsPresent = (itemBenefitsMoney - userOriginalMoney)*100/userOriginalMoney
        return benefitsPresent
    }
}
