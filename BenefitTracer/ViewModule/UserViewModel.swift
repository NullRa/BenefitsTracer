//
//  UserViewModel.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//

import Foundation
enum UserTableViewEventType {
    case addMoney, toggle
}

class UserViewModel {
    let userCellId = "UserCell"
    let moneyCellId = "MoneyCell"
    var list = [UserData]()
    let userRespository = UserRespository()
    
    func setList(){
        let userNameList = userRespository.queryUserCoreData()
        userNameList.forEach { (userName) in
            let userMoneyDatas = userRespository.queryMoneyCoreData(userName: userName)
            var moneyDatas = [MoneyData]()
            userMoneyDatas.forEach { (moneyString, addMoneyDate) in
                moneyDatas.append(MoneyData(moneyString: moneyString, date: addMoneyDate))
            }
            list.append(UserData(isOpen: false, money: moneyDatas, userName: userName))
        }
    }
    
    func addNewUser(userName:String){
        list.append(UserData(money: [MoneyData(moneyString: "Add Money", date: nil)], userName: userName))
        userRespository.insertUserCoreData(name: userName)
    }
    
    func addNewMoney(userIndex:Int,money:String){
        let date = Date()
        list[userIndex].money.insert(MoneyData(moneyString: money, date: date), at: list[userIndex].money.count-1)
        let username = list[userIndex].userName
        let moneyPrice = Int(money)!
        userRespository.insertMoneyCoreData(userName: username, money: moneyPrice, date: date)
    }
    
    func getSections() -> Int{
        return list.count
    }
    
    func getRows(userIndex:Int) -> Int {
        if list[userIndex].isOpen {
            return list[userIndex].money.count + 1
        } else {
            return 1
        }
    }
    
    func getUserName(userIndex:Int) -> String{
        return list[userIndex].userName
    }
    
    func getMoney(userIndex:Int,moneyIndex:Int) -> MoneyData{
        return list[userIndex].money[moneyIndex]
    }

    func getUserTotalMoney(userIndex:Int) -> Int {
        return list[userIndex].getUserTotalMoney()
    }

    func selectEvent(userIndex:Int,moneyIndex:Int) -> UserTableViewEventType {
        if list[userIndex].isOpen {
            if moneyIndex == -1 {//點username收起時
                list[userIndex].isOpen.toggle()
                return .toggle
            }
            if list[userIndex].money[moneyIndex].moneyString == "Add Money" {
                return .addMoney
            } else {
                list[userIndex].isOpen.toggle()
                return .toggle
            }
        } else {
            list[userIndex].isOpen.toggle()
            return .toggle
        }
    }

    func moneyIsNotEmpty(userIndex:Int) -> Bool {
        return list[userIndex].money.count > 1
    }
    
    func removeMoney(userIndex:Int,moneyIndex:Int) {
        guard let moneyDate = list[userIndex].money[moneyIndex].date else {
            assertionFailure("ERROR")
            return
        }
        let name = list[userIndex].userName
        list[userIndex].money.remove(at: moneyIndex)
        userRespository.deleteMoneyCoreData(userName: name, date: moneyDate)
    }
    
    func removeUser(userIndex:Int) {
        let name = list[userIndex].userName
        list.remove(at: userIndex)
        userRespository.deleteUserCoreData(name: name)
    }

    func getTotalMoney() -> Int {
        var totalMoney: Int = 0
        list.forEach { (userData) in
            userData.money.forEach { (moneyData) in
                if let moneyPrice = Int(moneyData.moneyString)  {
                    totalMoney = totalMoney + moneyPrice
                }
            }
        }
        return totalMoney
    }
}
