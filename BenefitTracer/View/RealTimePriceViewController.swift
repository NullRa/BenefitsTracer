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
    let realTimePriceViewModel = RealTimePriceViewModel()
    
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var realTimePriceTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        realTimePriceViewModel.setList()
        realTimePriceTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        bind()
        initUI()
    }
    
    func initUI(){
        realTimePriceTableView.tableFooterView = UIView()
        totalMoneyLabel.text = "Total Money: \(realTimePriceViewModel.orginalTotalMoney!) (+0%)"
        self.title = "Real Time Price"
    }
    
    func bind(){
        realTimePriceTableView.delegate = self
        realTimePriceTableView.dataSource = self
        realTimePriceViewModel.setList()
        realTimePriceViewModel.setOrginalTotalMoney()
    }
}

extension RealTimePriceViewController {
    
    func setTotalPriceLabel() {
        let newTotalMoney = realTimePriceViewModel.getTotlePrice()
        let totalBenefitsPresentString = realTimePriceViewModel.getTotalBenefitsString()
        totalMoneyLabel.text = "Total Money: \(newTotalMoney) (\(totalBenefitsPresentString))"
    }
}

extension RealTimePriceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realTimePriceViewModel.getListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: realTimePriceViewModel.cellId, for: indexPath)
        let item = realTimePriceViewModel.getListItem(itemIndex: indexPath.row)
        cell.textLabel?.text = item.0
        cell.detailTextLabel?.text = "\(item.1) (\(item.2))"
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
                self.realTimePriceViewModel.editAccountEvent(newMoney: newMoney, itemIndex: indexPath.row)
                tableView.reloadData()
                self.setTotalPriceLabel()
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
                self.realTimePriceViewModel.addBenefitsEvent(benefits: addBenefits, itemIndex: indexPath.row)
                tableView.reloadData()
                self.setTotalPriceLabel()
                
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
}
