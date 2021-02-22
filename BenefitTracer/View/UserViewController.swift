//
//  ViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/20.
//

import UIKit
//import CoreData

struct UserData {
    var isOpen:Bool = false
    var money:[String] = ["Add Money"]
    var userName:String
}

class UserViewController: UIViewController {
    
    let userViewModel = UserViewModel()
    
    @IBOutlet weak var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
        bind()
    }
    
    func initUI(){
        self.title = "User"
    }
    
    func bind(){
        userTableView.delegate = self
        userTableView.dataSource = self
        userViewModel.setList()
    }
    
}

//MARK: Function
extension UserViewController {
    func addUser(){
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)
        alert.addTextField { (testField) in
            testField.placeholder = "Enter User"
        }
        
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let userNameTextField = (alert.textFields?.first)! as UITextField
            let userName = userNameTextField.text!
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
        alert.addTextField { (testField) in
            testField.placeholder = "Enter Money"
        }
        
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let moneyTextField = (alert.textFields?.first)! as UITextField
            let money = moneyTextField.text!
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
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: userViewModel.moneyCellId, for: indexPath)
            cell.textLabel?.text = userViewModel.getMoney(userIndex: indexPath.section, moneyIndex: indexPath.row-1)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row - 1
        switch userViewModel.selectEvent(userIndex: section, moneyIndex: row) {
        case .addUser:
            addUser()
        case .addMoney:
            addMoney(section: section)
        case .toggle:
            let indexes = IndexSet(integer: section)
            tableView.reloadSections(indexes, with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if editingStyle == .delete {
            if row == 0{
                let user = userViewModel.getUserName(userIndex: section)
                if user == "Add User" {
                    print("不能刪 Add User")
                    alertMessage(title: "別亂點", message: "＝ ＝")
                } else {
                    if userViewModel.moneyIsNotEmpty(userIndex: section) {
                        print("使用者還有錢不能刪除")
                        alertMessage(title: "錢不要囉", message: "-.-")
                    } else {
                        userViewModel.removeUser(userIndex:section)
                        tableView.reloadData()
                    }
                }
            } else {
                let money = userViewModel.getMoney(userIndex: section, moneyIndex: row-1)
                if money == "Add Money" {
                    print("不能刪 Add Money")
                    alertMessage(title: "＝ ＝", message: "就跟你說不能點")
                } else {
                    userViewModel.removeMoney(userIndex: section, moneyIndex: row-1)
                    tableView.reloadData()
                }
            }
        }
    }
}
