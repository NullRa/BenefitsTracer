//
//  RealTimePriceViewModel.swift
//  BenefitTracer
//
//  Created by Apple on 2021/2/25.
//

import Foundation
class BenefitsViewModel {
    let cellId = "realTimePriceCell"

    let dataManager = DataManager.shared
    
    func addBenefits(benefitsMoney:Int, itemIndex:Int){
        dataManager.addBenefits(benefitsMoney: benefitsMoney, itemIndex: itemIndex)
    }
    
    func getListCount() -> Int {
        return dataManager.itemDataList.count
    }
    
    func getListItemToThreeWay(itemIndex: Int) -> (String,String,String) {
        //name,price,benefits
        return dataManager.getListItem(itemIndex:itemIndex)
    }
    
    func getListItem(itemIndex: Int) -> ItemData {
        return dataManager.getListItem2(itemIndex:itemIndex)
    }
    
    func getTotalMoney() -> Int {
        return dataManager.getTotalMoneyByUserData()
    }
    
    func getTotalPriceString() -> String{
        let origianlMoney = dataManager.getTotalMoneyByItemData()
        var benefitsMoney = 0
        dataManager.itemDataList.forEach { (itemData) in
            benefitsMoney = benefitsMoney + itemData.getMoneyWithBenefits()
        }
        let benefitsPresent = (benefitsMoney - origianlMoney)*100/origianlMoney
        return "Total Money: \(benefitsMoney) (\(benefitsPresent))"
    }
    
}
