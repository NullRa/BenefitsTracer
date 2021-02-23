//
//  MoneyViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
//

import UIKit
struct ItemData {
    let itemName:String
    var itemPrice:Int
}
class MoneyViewController: UIViewController {
    let itemCellId = "itemCell"
    var itemList: [ItemData] = []
    
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var moneyTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navVC = self.tabBarController?.viewControllers?[0] as? UINavigationController,
           let first = navVC.viewControllers[0] as? UserViewController{
            let totalMoney = first.userViewModel.getTotalMoney()
            self.title = "Total Money: \(totalMoney)"
            itemList.append(ItemData(itemName: "Richart", itemPrice: totalMoney))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
    }
    
    func initUI(){
        moneyTableView.tableFooterView = UIView()
    }
    
    func bind(){
        moneyTableView.delegate = self
        moneyTableView.dataSource = self
        addItemButton.setTitle("Add Item", for: .normal)
        addItemButton.addTarget(self, action: #selector(addItemEvent), for: .touchUpInside)
    }
    
    @objc func addItemEvent(){
        let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Enter Item Name"
        }
        alert.addTextField { (priceTextField) in
            priceTextField.placeholder = "Enter Item Price"
            priceTextField.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let nameTextField = (alert.textFields?.first)! as UITextField
            let name = nameTextField.text!
            let priceTextField = alert.textFields![1] as UITextField
            guard let price = Int(priceTextField.text!) else {
                self.alertMessage(title: "Price Format Error!")
                return
            }
            if name == "" {
                self.alertMessage(title: "Name is empty.")
                return
            }
            if price > self.itemList[0].itemPrice {
                self.alertMessage(title: "Money is not enough!")
                return
            }
            self.itemList[0].itemPrice = self.itemList[0].itemPrice - price
            self.itemList.append(ItemData(itemName: name, itemPrice: price))
            self.moneyTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertMessage(title:String,message:String?=nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Confirm", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension MoneyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moneyTableView.dequeueReusableCell(withIdentifier: itemCellId, for: indexPath)
        cell.textLabel?.text = itemList[indexPath.row].itemName
        cell.detailTextLabel?.text = "$: \(itemList[indexPath.row].itemPrice)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "DELETE") { (action, view, completionHandler) in
            if indexPath.row == 0 {
                self.alertMessage(title: "It can't delete.")
            } else {
                let deleteItem = self.itemList.remove(at: indexPath.row)
                self.itemList[0].itemPrice = self.itemList[0].itemPrice + deleteItem.itemPrice
                tableView.reloadData()
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = .darkGray
        
        let editAction = UIContextualAction(style: .normal, title: "EDIT") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
            alert.addTextField { (nameTextField) in
                nameTextField.text = self.itemList[indexPath.row].itemName
            }
            alert.addTextField { (priceTextField) in
                priceTextField.text = "\(self.itemList[indexPath.row].itemPrice)"
                priceTextField.keyboardType = .numberPad
            }
            let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                let nameTextField = (alert.textFields?.first)! as UITextField
                let name = nameTextField.text!
                let priceTextField = alert.textFields![1] as UITextField
                guard let price = Int(priceTextField.text!) else {
                    self.alertMessage(title: "Price Format Error!")
                    completionHandler(true)
                    return
                }
                if name == "" {
                    self.alertMessage(title: "Name is empty.")
                    completionHandler(true)
                    return
                }
                if price > (self.itemList[0].itemPrice + self.itemList[indexPath.row].itemPrice) {
                    self.alertMessage(title: "Money is not enough!")
                    completionHandler(true)
                    return
                }
                if indexPath.row == 0 {
                    self.alertMessage(title: "Can't edit orginal item.")
                    completionHandler(true)
                    return
                }
                let orginalMoney = self.itemList[indexPath.row].itemPrice
                if orginalMoney > price {
                    self.itemList[0].itemPrice = self.itemList[0].itemPrice + (self.itemList[indexPath.row].itemPrice - price)
                } else {
                    self.itemList[0].itemPrice = self.itemList[0].itemPrice - (price - self.itemList[indexPath.row].itemPrice)
                }
                self.itemList[indexPath.row].itemPrice = price
                self.moneyTableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        editAction.backgroundColor = .gray
        
        let addAction = UIContextualAction(style: .normal, title: "ADD") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
            alert.addTextField { (priceTextField) in
                priceTextField.placeholder = "Enter Extra Money"
                priceTextField.keyboardType = .numberPad
            }
            let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                let priceTextField = (alert.textFields?.first)! as UITextField
                guard let price = Int(priceTextField.text!) else {
                    self.alertMessage(title: "Price Format Error!")
                    completionHandler(true)
                    return
                }
                
                if price > self.itemList[0].itemPrice {
                    self.alertMessage(title: "Money is not enough!")
                    completionHandler(true)
                    return
                }
                if indexPath.row == 0 {
                    self.alertMessage(title: "Can't add orginal item.")
                    completionHandler(true)
                    return
                }
                self.itemList[0].itemPrice = self.itemList[0].itemPrice - price
                self.itemList[indexPath.row].itemPrice = self.itemList[indexPath.row].itemPrice + price
                self.moneyTableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        addAction.backgroundColor = .lightGray
        
        let prevention = UISwipeActionsConfiguration(actions: [deleteAction, editAction, addAction])
        prevention.performsFirstActionWithFullSwipe = false
        return prevention
    }
}
