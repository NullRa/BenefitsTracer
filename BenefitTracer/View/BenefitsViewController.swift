//
//  BenefitsViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
//

import UIKit


class BenefitsViewController: UIViewController {
    let benefitsViewModel = BenefitsViewModel()
    
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var realTimePriceTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        realTimePriceTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        bind()
        initUI()
    }
    
    func initUI(){
        realTimePriceTableView.tableFooterView = UIView()
        totalMoneyLabel.text = "Total Money: \(benefitsViewModel.getTotalMoney()) (+0%)"
        self.title = "Benefits"
    }
    
    func bind(){
        realTimePriceTableView.delegate = self
        realTimePriceTableView.dataSource = self
    }
}

extension BenefitsViewController {
    
    func setTotalPriceLabel() {
        totalMoneyLabel.text = benefitsViewModel.getTotalPriceString()
    }
}

extension BenefitsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return benefitsViewModel.getListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: benefitsViewModel.cellId, for: indexPath)
        let item = benefitsViewModel.getListItem(itemIndex: indexPath.row)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.getMoneyWithBenefits()) (\(item.benefits))"
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
                let oldMoney = self.benefitsViewModel.getListItem(itemIndex:indexPath.row).getMoneyWithBenefits()
                let benefitsMoney = newMoney - oldMoney
                self.benefitsViewModel.addBenefits(benefitsMoney: benefitsMoney, itemIndex: indexPath.row)
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
                self.benefitsViewModel.addBenefits(benefitsMoney: addBenefits, itemIndex: indexPath.row)
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
