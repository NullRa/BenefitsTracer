//
//  ViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/20.
//

import UIKit

class UserViewController: UIViewController {
    //test
    let userViewModel = UserViewModel()
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var addUserButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
        bind()
    }
    
    func initUI(){
        self.title = "User"
        userTableView.tableFooterView = UIView()
        addUserButton.setTitle("Add User", for: .normal)
    }
    
    func bind(){
        userTableView.delegate = self
        userTableView.dataSource = self
        addUserButton.addTarget(self, action: #selector(addUser), for: .touchUpInside)
    }
    
}

//MARK: Function
extension UserViewController {
    @objc func addUser(){
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter User"
        }
        
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let userNameTextField = (alert.textFields?.first)! as UITextField
            let userName = userNameTextField.text!
            if userName == "" {
                self.alertMessage(title: "Name is empty.")
                return
            }
            self.userViewModel.addNewUser(userName:userName)
            self.userTableView.reloadData()
            
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addMoney(section:Int){
        let alert = UIAlertController(title: "Add Money", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Money"
            textField.keyboardType = .numberPad
        }
        
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let moneyTextField = (alert.textFields?.first)! as UITextField
            let moneyString = moneyTextField.text!
            guard let money = Float(moneyString) else {
                self.alertMessage(title: "Price Format Error!")
                return
            }
            self.userViewModel.addNewMoney(userIndex: section, money: money)
            self.userTableView.reloadData()
            
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
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

//MARK:- UITableViewDelegate, UITableViewDataSource
extension UserViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return userViewModel.getSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModel.getRows(userIndex:section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: userViewModel.userCellId, for: indexPath)
            cell.textLabel?.text = userViewModel.getUserName(userIndex:indexPath.section)
            cell.detailTextLabel?.text = "\(userViewModel.getUserTotalMoney(userIndex: indexPath.section))"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: userViewModel.moneyCellId, for: indexPath)
            let moneyData = userViewModel.getMoney(userIndex: indexPath.section, moneyIndex: indexPath.row-1)
            let price: String! = String(format: "%.2f", moneyData.moneyPriceWithBenefits)
            let present: String! = String(format: "%.2f", moneyData.totalBenefits*100)
            cell.textLabel?.text = "Price: \(price!) (\(present!)%)"
            
            if let date = moneyData.date {
                let dateFormatter: DateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                let dateFormatString: String = dateFormatter.string(from: date)
                cell.detailTextLabel?.text = "Add Time: " + dateFormatString
            } else {
                cell.detailTextLabel?.text = ""
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userViewModel.selectEvent(userIndex: indexPath.section, moneyIndex: indexPath.row-1)
        let indexes = IndexSet(integer: indexPath.section)
        tableView.reloadSections(indexes, with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "DELETE") { (action, view, completionHandler) in
            let section = indexPath.section
            let row = indexPath.row
            if row == 0{
                if self.userViewModel.moneyIsNotEmpty(userIndex: section) {
                    self.alertMessage(title: "This account is not empty.", message: "Can't Delete")
                } else {
                    self.userViewModel.removeUser(userIndex:section)
                    tableView.reloadData()
                }
            } else {
                if let errorMsg = self.userViewModel.removeMoney(userIndex: section, moneyIndex: row-1) {
                    self.alertMessage(title: errorMsg, message: "Can't Delete")
                } else {
                    tableView.reloadData()
                }
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = .darkGray
        
        let addAction = UIContextualAction(style: .normal, title: "ADD Money") { (action, view, conpletionHandler) in
            self.addMoney(section: indexPath.section)
            conpletionHandler(true)
        }
        addAction.backgroundColor = .gray
        
        var prevention: UISwipeActionsConfiguration!
        if indexPath.row == 0 {
            prevention = UISwipeActionsConfiguration(actions: [deleteAction,addAction])
        } else {
            prevention = UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        prevention.performsFirstActionWithFullSwipe = false
        return prevention
    }
}
