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
    let dataManager = DataManager.shared
    
    func addNewUser(userName:String){
        dataManager.addUser(userName: userName)
    }
    
    func addNewMoney(userIndex:Int,money:String){
        dataManager.addMoney(userIndex:userIndex,money:money)
    }
    
    func getSections() -> Int{
        return dataManager.userDataList.count
    }
    
    func getRows(userIndex:Int) -> Int {
        if dataManager.userDataList[userIndex].isOpen {
            return dataManager.userDataList[userIndex].money.count + 1
        } else {
            return 1
        }
    }
    
    func getUserName(userIndex:Int) -> String{
        return dataManager.userDataList[userIndex].userName
    }
    
    func getMoney(userIndex:Int,moneyIndex:Int) -> MoneyData{
        return dataManager.userDataList[userIndex].money[moneyIndex]
    }

    func getUserTotalMoney(userIndex:Int) -> Int {
        return dataManager.userDataList[userIndex].getUserTotalMoney()
    }

    func selectEvent(userIndex:Int,moneyIndex:Int) -> UserTableViewEventType {
        if dataManager.userDataList[userIndex].isOpen {
            if moneyIndex == -1 {//點username收起時
                dataManager.userDataList[userIndex].isOpen.toggle()
                return .toggle
            }
            if dataManager.userDataList[userIndex].money[moneyIndex].moneyString == "Add Money" {
                return .addMoney
            } else {
                dataManager.userDataList[userIndex].isOpen.toggle()
                return .toggle
            }
        } else {
            dataManager.userDataList[userIndex].isOpen.toggle()
            return .toggle
        }
    }

    func moneyIsNotEmpty(userIndex:Int) -> Bool {
        return dataManager.userDataList[userIndex].money.count > 1
    }
    
    func removeMoney(userIndex:Int,moneyIndex:Int) -> String? {
        if dataManager.removeMoneyResult(userIndex: userIndex, moneyIndex: moneyIndex) {
            return nil
        } else {
            return "Bank money is not enough."
        }
    }
    
    func removeUser(userIndex:Int) {
        dataManager.removeUser(userIndex:userIndex)
    }

    func getTotalMoney() -> Int {
        return dataManager.getTotalMoneyByUserData()
    }
}
