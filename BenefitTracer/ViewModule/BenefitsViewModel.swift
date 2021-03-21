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
    
    func addBenefits(benefitsMoney:Float, itemIndex:Int){
        dataManager.addBenefits(benefitsMoney: benefitsMoney, itemIndex: itemIndex)
    }
    
    func getListCount() -> Int {
        return dataManager.itemDataList.count
    }
    
    func getListItem(itemIndex: Int) -> ItemData {
        return dataManager.getListItem(itemIndex:itemIndex)
    }
    
    func getTotalMoney() -> Float {
        return dataManager.getTotalMoneyByUserData()
    }
    
    func getTotalPriceString() -> String{
        let originalMoney = dataManager.getOriginalTotalMoneyByItemData()
        let benefitsMoney = dataManager.getTotalMoneyByItemData()
        
        var benefitsPresent:Float {
            if originalMoney == 0.0 {
                return 0.0
            } else {
                return (benefitsMoney - originalMoney)*100/originalMoney
            }
        }
        let benefitsPresentString: String! = String(format: "%.2f", benefitsPresent)
        return "Total Money: \(benefitsMoney) (\(benefitsPresentString!)%)"
    }
}
