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
    var benefits: [Float]
    var moneyPriceWithBenefits: Float{
        var totalMoney:Float = moneyPrice
        benefits.forEach { (benefit) in
            totalMoney = totalMoney + moneyPrice * benefit
        }
        return totalMoney
    }
    var totalBenefits:Float{
        var totalBenefits:Float = 0
        benefits.forEach { (benefit) in
            if totalBenefits == 0 {
                totalBenefits = 1+benefit
            } else {
                totalBenefits = totalBenefits * (1 + benefit)
            }
        }
        return totalBenefits*100
    }
}

struct UserData {
    var isOpen:Bool = false
    var money:[MoneyData] = []
    var userName:String
    var totalMoney: Float{
        var totalMoney:Float = 0
        money.forEach {
            (moneyData) in
            totalMoney = totalMoney + moneyData.moneyPriceWithBenefits
        }
        return totalMoney
    }
}

struct ItemData {
    var name:String
    var money:Float
    var benefits: Float = 0
    var benefitsString:String {
        if benefits >= 0 {
            return "+\(benefits*100)%"
        } else {
            return "\(benefits*100)%"
        }
    }
    func getMoneyWithBenefits() -> Float{
        
        return (money + money*benefits)
    }
    func getBenefitsMoney() -> Float{
        return money*benefits
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
//        resetCoreData()
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
        userDataList[userIndex].money.append(MoneyData(moneyPrice: money, date: date, benefits: []))
        let username = userDataList[userIndex].userName
        let moneyPrice = money
        respository.insertMoneyCoreData(userName: username, money: moneyPrice, date: date)
        addUnHandleMoney(extraPrice: money)
    }

    func removeMoneyResult(userIndex:Int,moneyIndex:Int) -> Bool {
        guard let moneyDate = userDataList[userIndex].money[moneyIndex].date else {
            assertionFailure("ERROR")
            return false
        }
        let name = userDataList[userIndex].userName
        let money = userDataList[userIndex].money[moneyIndex].moneyPriceWithBenefits
        if money > itemDataList[0].getMoneyWithBenefits() {
            return false
        }
        userDataList[userIndex].money.remove(at: moneyIndex)
        itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() - money
        itemDataList[0].benefits = 0
        respository.updateItemCoreData(name: itemDataList[0].name, newMoney: itemDataList[0].money, newName: nil, benefits: 0)
        respository.deleteMoneyCoreData(userName: name, date: moneyDate)
        return true
    }

    func getTotalMoneyByUserData() -> Float {
        var totalMoney: Float = 0
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
    
    func getTotalMoneyByItemData() -> Float {
        var totalMoney: Float = 0
        itemDataList.forEach { (itemData) in
            totalMoney = totalMoney + itemData.getMoneyWithBenefits()
        }
        return totalMoney
    }
    
    func getOriginalTotalMoneyByItemData() -> Float {
        var totalMoney: Float = 0
        itemDataList.forEach { (itemData) in
            totalMoney = totalMoney + itemData.money
        }
        return totalMoney
    }

    func addItemIsSuccessful(itemName:String, money:Float) -> Bool {
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
    
    func editItemIsSuccessful(itemID:Int,newName:String,newPrice:Float) -> Bool {
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
    
    func addExtraMoneyIsSuccessful(itemID:Int,extraPrice:Float) -> Bool {
        if itemID == 0 {
            //FIXME
            assertionFailure("ERROR ITEM0")
        }
        if extraPrice > itemDataList[0].getMoneyWithBenefits() {
            return false
        }
        itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() - extraPrice
        respository.updateItemCoreData(name: itemDataList[0].name, newMoney: itemDataList[0].money, benefits: 0)
        let benefitsMoney = itemDataList[itemID].getBenefitsMoney()
        itemDataList[itemID].money = itemDataList[itemID].money + extraPrice
        itemDataList[itemID].benefits = benefitsMoney/itemDataList[itemID].money
        respository.updateItemCoreData(name: itemDataList[itemID].name, newMoney: itemDataList[itemID].money, benefits: itemDataList[itemID].benefits)
        return true
    }
    
    func addUnHandleMoney(extraPrice:Float){
        itemDataList[0].money = itemDataList[0].getMoneyWithBenefits() + extraPrice
        respository.updateItemCoreData(name: itemDataList[0].name, newMoney: itemDataList[0].money, benefits: 0)
    }
    
    func editUnHandleMoney(extraPrice:Float){
        itemDataList[0].benefits = (itemDataList[0].getMoneyWithBenefits() - itemDataList[0].money + extraPrice )/itemDataList[0].money
        respository.updateItemCoreData(name: itemDataList[0].name, newMoney: itemDataList[0].money, benefits: itemDataList[0].benefits)
    }
    
    // MARK: - BenefitsView
    
    func getListItem(itemIndex: Int) -> ItemData {
        return itemDataList[itemIndex]
    }
     
    func addBenefits(benefitsMoney:Float, itemIndex:Int){
        //FIXME被除數等於零
        itemDataList[itemIndex].benefits = (benefitsMoney+itemDataList[itemIndex].getBenefitsMoney()) / itemDataList[itemIndex].money
        respository.updateItemCoreData(name: itemDataList[itemIndex].name, newMoney: itemDataList[itemIndex].money, benefits: itemDataList[itemIndex].benefits)

        let benefitsPresent = getTotalBenefits()
        updateUserDataListBenefits(benefitsPresent: benefitsPresent)
    }

    func getTotalBenefits() -> Float{
        var itemBenefitsMoney:Float = 0
        itemDataList.forEach { (itemData) in
            itemBenefitsMoney = itemBenefitsMoney + itemData.getMoneyWithBenefits()
        }

        var originalUserBenefitsMoney:Float = 0
        userDataList.forEach { (userData) in
            originalUserBenefitsMoney = originalUserBenefitsMoney + userData.totalMoney
        }

        var benefitsPresent:Float = 0
        benefitsPresent = (itemBenefitsMoney - originalUserBenefitsMoney)/originalUserBenefitsMoney
        return benefitsPresent
    }

    func updateUserDataListBenefits(benefitsPresent:Float){
        for i in 0 ..< userDataList.count {
            for j in 0 ..< userDataList[i].money.count {
                userDataList[i].money[j].benefits.append(benefitsPresent)
            }
        }
        respository.insertBenefitsCoreData(benefits: benefitsPresent)
    }
}
