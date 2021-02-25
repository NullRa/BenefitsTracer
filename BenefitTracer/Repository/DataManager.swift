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

    init() {
        setUserViewModelList()
    }

    // MARK: - UserView
    func setUserViewModelList(){
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

    func addNewUser(userName:String) {
        userDataList.append(UserData(money: [MoneyData(moneyString: "Add Money", date: nil)], userName: userName))
        respository.insertUserCoreData(name: userName)
    }

    func removeUser(userIndex:Int) {
        let name = userDataList[userIndex].userName
        userDataList.remove(at: userIndex)
        respository.deleteUserCoreData(name: name)
    }

    func addNewMoney(userIndex:Int,money:String){
        let date = Date()
        userDataList[userIndex].money.insert(MoneyData(moneyString: money, date: date), at: userDataList[userIndex].money.count-1)
        let username = userDataList[userIndex].userName
        let moneyPrice = Int(money)!
        respository.insertMoneyCoreData(userName: username, money: moneyPrice, date: date)
    }

    func removeMoney(userIndex:Int,moneyIndex:Int) {
        guard let moneyDate = userDataList[userIndex].money[moneyIndex].date else {
            assertionFailure("ERROR")
            return
        }
        let name = userDataList[userIndex].userName
        userDataList[userIndex].money.remove(at: moneyIndex)
        respository.deleteMoneyCoreData(userName: name, date: moneyDate)
    }

    func getTotalMoney() -> Int {
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
}
