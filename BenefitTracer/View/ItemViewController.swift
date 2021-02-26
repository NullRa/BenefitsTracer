//
//  MoneyViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
// 

import UIKit

class ItemViewController: UIViewController {
    let itemViewModel = ItemViewModel()
    
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var addItemButton: UIButton!
    @IBOutlet weak var moneyTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        totalMoneyLabel.text = "Total Money: \(itemViewModel.getTotalMoney())"
        itemViewModel.setList()
        moneyTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
    }
    
    func initUI(){
        self.title = "Item"
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
            
            if let errorMsg = self.itemViewModel.addItemResult(name: name, price: price) {
                self.alertMessage(title: errorMsg)
            } else {
                self.moneyTableView.reloadData()
            }
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

extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemViewModel.getListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moneyTableView.dequeueReusableCell(withIdentifier: itemViewModel.itemCellId, for: indexPath)
        cell.textLabel?.text = itemViewModel.getItemName(itemID: indexPath.row)
        cell.detailTextLabel?.text = "$: \(itemViewModel.getItemPrice(itemID: indexPath.row))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "DELETE") { (action, view, completionHandler) in
            if indexPath.row == 0 {
                self.alertMessage(title: "It couldn't delete.")
            } else {
                self.itemViewModel.removeItem(itemID: indexPath.row)
                tableView.reloadData()
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = .darkGray
        
        let editAction = UIContextualAction(style: .normal, title: "EDIT") { (action, view, completionHandler) in
            let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
            alert.addTextField { (nameTextField) in
                nameTextField.text = self.itemViewModel.getItemName(itemID: indexPath.row)
            }
            alert.addTextField { (priceTextField) in
                priceTextField.text = "\(self.itemViewModel.getItemPrice(itemID: indexPath.row))"
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
                if indexPath.row == 0 {
                    self.alertMessage(title: "Can't edit orginal item.")
                    completionHandler(true)
                    return
                }
                
                if let errorMsg = self.itemViewModel.editItemResult(itemID: indexPath.row, newName: name, newPrice: price) {
                    self.alertMessage(title: errorMsg)
                    completionHandler(true)
                    return
                }
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
                if indexPath.row == 0 {
                    self.alertMessage(title: "Can't add orginal item.")
                    completionHandler(true)
                    return
                }
                
                if let errorMsg = self.itemViewModel.addExtraItemPriceResult(itemID: indexPath.row, extraPrice: price) {
                    self.alertMessage(title: errorMsg)
                    completionHandler(true)
                    return
                }
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
