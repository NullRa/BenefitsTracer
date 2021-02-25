//
//  BenefitsViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
//

import UIKit

struct ItemDataWithBenefits {
    var itemData: ItemData
    var benefits: Int
    var benefitsString:String {
        if benefits >= 0 {
            return "+\(benefits)%"
        } else {
            return "\(benefits)%"
        }
    }
}
class RealTimePriceViewController: UIViewController {
    let realTimePriceCellCellId = "realTimePriceCell"
    var itemList: [ItemDataWithBenefits] = []
    let userRespository = UserRespository()
    
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var realTimePriceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        bind()
        initUI()
    }
    
    func initUI(){
        realTimePriceTableView.tableFooterView = UIView()
        totalMoneyLabel.text = "Total Money: \(getTotlePrice()) (+0%)"
        self.title = "Real Time Price"
    }
    
    func bind(){
        realTimePriceTableView.delegate = self
        realTimePriceTableView.dataSource = self
        setList()
    }
}

extension RealTimePriceViewController {
    func setList(){
        let itemDict = userRespository.queryItemCoreData()
        for (name,price) in itemDict {
            itemList.append(ItemDataWithBenefits(itemData: ItemData(itemName: name, itemPrice: price), benefits: 0))
        }
    }
    
    func getTotlePrice() -> Int {
        var totalPrice = 0
        itemList.forEach { (item) in
            totalPrice = totalPrice + item.itemData.itemPrice
        }
        return totalPrice
    }
}

extension RealTimePriceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: realTimePriceCellCellId, for: indexPath)
        cell.textLabel?.text = itemList[indexPath.row].itemData.itemName
        cell.detailTextLabel?.text = "\(itemList[indexPath.row].itemData.itemPrice) (\(itemList[indexPath.row].benefitsString))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "EDIT") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Edit Accounts", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter New Money"
                textField.keyboardType = .numberPad
            }
            let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                let textField = (alert.textFields?.first)! as UITextField
                let newMoney = Int(textField.text!)!
                self.editAccountEvent(newMoney: newMoney, itemIndex: indexPath.row)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        editAction.backgroundColor = .gray
        let addAction = UIContextualAction(style: .normal, title: "ADD") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Add Benefits", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Enter Add Benefits"
                textField.keyboardType = .numberPad
            }
            let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                let textField = (alert.textFields?.first)! as UITextField
                let addBenefits = Int(textField.text!)!
                self.addBenefitsEvent(benefits: addBenefits, itemIndex: indexPath.row)
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        editAction.backgroundColor = .lightGray
        let prevention = UISwipeActionsConfiguration(actions: [editAction, addAction])
        prevention.performsFirstActionWithFullSwipe = false
        return prevention
    }
    
    func editAccountEvent(newMoney:Int,itemIndex:Int){
        itemList[itemIndex].benefits = (newMoney - itemList[itemIndex].itemData.itemPrice)*100/itemList[itemIndex].itemData.itemPrice
        itemList[itemIndex].itemData.itemPrice = newMoney
        realTimePriceTableView.reloadData()
    }
    func addBenefitsEvent(benefits:Int,itemIndex:Int){
        itemList[itemIndex].benefits = benefits*100/itemList[itemIndex].itemData.itemPrice
        itemList[itemIndex].itemData.itemPrice = itemList[itemIndex].itemData.itemPrice + benefits
        realTimePriceTableView.reloadData()
    }
}
