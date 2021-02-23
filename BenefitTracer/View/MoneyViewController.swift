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
            let price = Int(priceTextField.text!)!
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
}
