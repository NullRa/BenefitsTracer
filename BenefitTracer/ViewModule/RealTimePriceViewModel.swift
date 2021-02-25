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
    let userRespository = UserRespository()
    var orginalTotalMoney: Int!
    
    func setList(){
        let itemDict = userRespository.queryItemCoreData()
        for (name,price) in itemDict {
            itemList.append(ItemDataWithBenefits(itemData: ItemData(itemName: name, itemPrice: price), benefits: 0))
        }
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
        itemList[itemIndex].benefits = (newMoney - itemList[itemIndex].itemData.itemPrice)*100/itemList[itemIndex].itemData.itemPrice
        itemList[itemIndex].itemData.itemPrice = newMoney
    }
    
    func addBenefitsEvent(benefits:Int,itemIndex:Int){
        itemList[itemIndex].benefits = benefits*100/itemList[itemIndex].itemData.itemPrice
        itemList[itemIndex].itemData.itemPrice = itemList[itemIndex].itemData.itemPrice + benefits
    }
    
    func getTotalBenefitsString() -> String {
        let newTotalMoney = getTotlePrice()
        let totalBenefitsPresent = (newTotalMoney-orginalTotalMoney)*100/orginalTotalMoney
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
