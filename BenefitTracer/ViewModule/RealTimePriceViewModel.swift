//
//  RealTimePriceViewModel.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/25.
//

import Foundation
class RealTimePriceViewModel {
    let cellId = "realTimePriceCell"
    var itemList: [ItemDataWithBenefits] = []
    let respository = Respository()
    var orginalTotalMoney: Int!
    
    func setList(){
        itemList.removeAll()
        let itemDict = respository.queryItemCoreData()
        for (name,price) in itemDict {
            itemList.append(ItemDataWithBenefits(itemData: ItemData(itemName: name, itemPrice: price), benefits: 0))
        }
    }
    
    func setOrginalTotalMoney(){
        orginalTotalMoney = getTotlePrice()
    }
    
    func getTotlePrice() -> Int {
        var totalPrice = 0
        itemList.forEach { (item) in
            totalPrice = totalPrice + item.itemData.itemPrice
        }
        return totalPrice
    }
    
    func editAccountEvent(newMoney:Int,itemIndex:Int){
        if itemList[itemIndex].itemData.itemPrice == 0 {
            itemList[itemIndex].benefits = 100
            itemList[itemIndex].itemData.itemPrice = newMoney
            updateItemCoreData()
            return
        }
        itemList[itemIndex].benefits = (newMoney - itemList[itemIndex].itemData.itemPrice)*100/itemList[itemIndex].itemData.itemPrice
        itemList[itemIndex].itemData.itemPrice = newMoney
        updateItemCoreData()
    }
    
    func addBenefitsEvent(benefits:Int,itemIndex:Int){
        if itemList[itemIndex].itemData.itemPrice == 0 {
            itemList[itemIndex].benefits = 100
            itemList[itemIndex].itemData.itemPrice = itemList[itemIndex].itemData.itemPrice + benefits
            updateItemCoreData()
            return
        }
        itemList[itemIndex].benefits = benefits*100/itemList[itemIndex].itemData.itemPrice
        itemList[itemIndex].itemData.itemPrice = itemList[itemIndex].itemData.itemPrice + benefits
        updateItemCoreData()
    }
    
    func updateItemCoreData(){
        respository.deleteAllItemCoreData()
        for i in 0 ..< itemList.count {
            respository.insertItemCoreData(name: itemList[i].itemData.itemName, price: itemList[i].itemData.itemPrice, id: i)
        }
    }
    
    func updateMoneyCoreData(benefitsPresent:Int){
        var userList = [UserData]()
        let userNameList = respository.queryUserCoreData()
        userNameList.forEach { (userName) in
            let userMoneyDatas = respository.queryMoneyCoreData(userName: userName)
            var moneyDatas = [MoneyData]()
            userMoneyDatas.forEach { (moneyString, addMoneyDate) in
                moneyDatas.append(MoneyData(moneyString: moneyString, date: addMoneyDate))
            }
            userList.append(UserData(isOpen: false, money: moneyDatas, userName: userName))
        }
        
        for i in 0 ..< userList.count {
            let userData = userList[i]
            respository.deleteAllMoneyCoreData(userName: userData.userName)
            for j in 0 ..< userData.money.count {
                let date = userData.money[j].date
                if userData.money[j].moneyString != "Add Money" {
                    let money = Int(userData.money[j].moneyString)!
                    let newMoney = money + money*benefitsPresent/100
                    respository.insertMoneyCoreData(userName: userData.userName, money: newMoney, date: date!)
                }
            }
        }
        
        
    }
    
    func getTotalBenefitsString() -> String {
        let newTotalMoney = getTotlePrice()
        let totalBenefitsPresent = (newTotalMoney-orginalTotalMoney)*100/orginalTotalMoney
        updateMoneyCoreData(benefitsPresent: totalBenefitsPresent)
        return totalBenefitsPresent >= 0 ? "+\(totalBenefitsPresent)%" : "\(totalBenefitsPresent)%"
    }
    
    func getListCount() -> Int {
        return itemList.count
    }
    
    func getListItem(itemIndex: Int) -> (String,String,String) {
        //name,price,benefits
        let name = itemList[itemIndex].itemData.itemName
        let price = "\(itemList[itemIndex].itemData.itemPrice)"
        let benefits = itemList[itemIndex].benefitsString
        return (name,price,benefits)
    }
}
