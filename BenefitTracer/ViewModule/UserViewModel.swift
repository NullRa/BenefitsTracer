//
//  UserViewModel.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//

import Foundation

class UserViewModel {
    let userCellId = "UserCell"
    let moneyCellId = "MoneyCell"
    let dataManager = DataManager.shared
    
    func addNewUser(userName:String){
        dataManager.addUser(userName: userName)
    }
    
    func addNewMoney(userIndex:Int,money:Float){
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
    
    func getUserTotalMoney(userIndex:Int) -> Float {
        return dataManager.userDataList[userIndex].totalMoney
    }
    
    func moneyIsNotEmpty(userIndex:Int) -> Bool {
        return dataManager.userDataList[userIndex].money.count > 0
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
    
    func getTotalMoney() -> Float {
        return dataManager.getTotalMoneyByUserData()
    }
    
    func selectEvent(userIndex:Int,moneyIndex:Int) {
        dataManager.userDataList[userIndex].isOpen.toggle()
    }
}
