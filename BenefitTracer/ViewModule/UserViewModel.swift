//
//  UserViewModel.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/22.
//

import Foundation
enum UserTableViewEventType {
    case addMoney, addUser, toggle
}
class UserViewModel {
    let userCellId = "UserCell"
    let moneyCellId = "MoneyCell"
    var list:[UserData]!
    let userRespository = UserRespository()
    
    func setList(){
        list = userRespository.queryUserCoreData()
        list.append(UserData(userName: "Add User"))
    }
    
    func addNewUser(userName:String){
        list.insert(UserData(userName: userName), at: self.list.count-1)
        userRespository.insertUserCoreData(name: userName)
    }
    
    func addNewMoney(userIndex:Int,money:String){
        list[userIndex].money.insert(money, at: list[userIndex].money.count-1)
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
    
    func getMoney(userIndex:Int,moneyIndex:Int) -> String{
        return list[userIndex].money[moneyIndex]
    }
    
    func selectEvent(userIndex:Int,moneyIndex:Int) -> UserTableViewEventType {
        if list[userIndex].isOpen {
            if moneyIndex == -1 {//點username收起時
                list[userIndex].isOpen.toggle()
                return .toggle
            }
            if list[userIndex].money[moneyIndex] == "Add Money" {
                return .addMoney
            } else {
                list[userIndex].isOpen.toggle()
                return .toggle
            }
        } else {
            if list[userIndex].userName == "Add User" {
                return .addUser
            } else {
                list[userIndex].isOpen.toggle()
                return .toggle
            }
        }
    }
    
    func moneyIsNotEmpty(userIndex:Int) -> Bool {
        return list[userIndex].money.count > 1
    }
    
    func removeMoney(userIndex:Int,moneyIndex:Int) {
        list[userIndex].money.remove(at: moneyIndex)
    }
    
    func removeUser(userIndex:Int) {
        let name = list[userIndex].userName
        list.remove(at: userIndex)
        userRespository.deleteUserCoreData(name: name)
    }
}
