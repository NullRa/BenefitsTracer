//
//  MoneyViewModel.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/23.
//

import Foundation

class MoneyViewModel {
    let itemCellId = "itemCell"
    var itemList: [ItemData] = []
    
    func addTotal(name:String, price:Int){
        itemList.append(ItemData(itemName: name, itemPrice: price))
    }
    
    //新增失敗回傳錯誤訊息
    func addItemResult(name:String, price:Int) -> String? {
        if price > itemList[0].itemPrice {
            return "Money is not enough!"
        }
        itemList[0].itemPrice = self.itemList[0].itemPrice - price
        addTotal(name: name, price: price)
        return nil
    }
    
    func getListCount() -> Int {
        return itemList.count
    }
    
    func getItemName(itemID:Int) -> String {
        return itemList[itemID].itemName
    }
    func getItemPrice(itemID:Int) -> Int {
        return itemList[itemID].itemPrice
    }
    func removeItem(itemID:Int){
        let deleteItem = self.itemList.remove(at: itemID)
        self.itemList[0].itemPrice = self.itemList[0].itemPrice + deleteItem.itemPrice
    }
    //編輯失敗回傳錯誤訊息
    func editItemResult(itemID:Int,newName:String,newPrice:Int) -> String? {
        let oldPrice = itemList[itemID].itemPrice
        if newPrice > itemList[0].itemPrice + oldPrice {
            return "Money is not enough!"
        }
        if oldPrice > newPrice {
            itemList[0].itemPrice = itemList[0].itemPrice + (oldPrice - newPrice)
        } else {
            itemList[0].itemPrice = itemList[0].itemPrice - (newPrice - oldPrice)
        }
        itemList[itemID].itemPrice = newPrice
        
        return nil
    }
    //新增額外金額失敗回傳錯誤訊息
    func addExtraItemPriceResult(itemID:Int,extraPrice:Int) -> String? {
        if extraPrice > itemList[0].itemPrice {
            return "Money is not enough!"
        }
        itemList[0].itemPrice = itemList[0].itemPrice - extraPrice
        itemList[itemID].itemPrice = itemList[itemID].itemPrice + extraPrice
        return nil
    }
}
