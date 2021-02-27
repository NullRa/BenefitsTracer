//
//  MoneyViewModel.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/23.
//

import Foundation
 
class ItemViewModel {
    let itemCellId = "itemCell"
    let dataManager = DataManager.shared
    
    func setList(){
        let extraMoney = dataManager.getTotalMoneyByUserData() - dataManager.getTotalMoneyByItemData()
        if extraMoney != 0 {
            editUnHandleMoney(extraPrice: extraMoney)
        }
    }
    
    //新增失敗回傳錯誤訊息
    func addItemResult(name:String, price:Int) -> String? {
        if dataManager.addItemIsSuccessful(itemName: name, money: price) {
            return nil
        } else {
            return "Money is not enough!"
        }
    }
    
    func getListCount() -> Int {
        return dataManager.itemDataList.count
    }
    
    func getItemName(itemID:Int) -> String {
        return dataManager.itemDataList[itemID].name
    }
    func getItemPrice(itemID:Int) -> Int {
        return dataManager.itemDataList[itemID].getMoneyWithBenefits()
    }
    func removeItem(itemID:Int){
        dataManager.removeItem(itemID: itemID)
    }
    func getTotalMoney() -> Int{
        return dataManager.getTotalMoneyByUserData()
    }
    
    //編輯失敗回傳錯誤訊息
    func editItemResult(itemID:Int,newName:String,newPrice:Int) -> String? {
        if dataManager.editItemIsSuccessful(itemID: itemID, newName: newName, newPrice: newPrice) {
            return nil
        } else {
            return "Money is not enough!"
        }
    }
    
    //新增額外金額失敗回傳錯誤訊息
    func addExtraItemPriceResult(itemID:Int,extraPrice:Int) -> String? {
        if dataManager.addExtraMoneyIsSuccessful(itemID: itemID, extraPrice: extraPrice) {
            return nil
        } else {
            return "Money is not enough!"
        }
    }
    
    func editUnHandleMoney(extraPrice: Int){
        dataManager.editUnHandleMoney(extraPrice: extraPrice)
    }
}
