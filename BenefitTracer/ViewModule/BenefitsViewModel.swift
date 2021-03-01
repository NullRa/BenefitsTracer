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

    func getListItem(itemIndex: Int) -> ItemData {
        return dataManager.getListItem(itemIndex:itemIndex)
    }
    
    func getTotalMoney() -> Int {
        return dataManager.getTotalMoneyByUserData()
    }
    
    func getTotalPriceString() -> String{
        let originalMoney = dataManager.getTotalMoneyByItemData()
        var benefitsMoney = 0
        dataManager.itemDataList.forEach { (itemData) in
            benefitsMoney = benefitsMoney + itemData.getMoneyWithBenefits()
        }
        let benefitsPresent = (benefitsMoney - originalMoney)*100/originalMoney
        return "Total Money: \(benefitsMoney) (\(benefitsPresent))"
    }
}
