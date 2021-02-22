//
//  ViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/20.
//

import UIKit

struct UserData {
    var isOpen:Bool = false
    var money:[String] = ["Add Money"]
    var userName:String
}

class UserViewController: UIViewController {

    let userCellId = "UserCell"
    let moneyCellId = "MoneyCell"

    var list:[UserData] = [UserData(userName: "Add User")]

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
    }

    func addUser(){
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)
        alert.addTextField { (testField) in
            testField.placeholder = "Enter User"
        }

        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let userNameTextField = (alert.textFields?.first)! as UITextField
            let userName = userNameTextField.text!
            self.list.insert(UserData(userName: userName), at: self.list.count-1)
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
            self.list[section].money.insert(money, at: self.list[section].money.count-1)
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
}

extension UserViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list[section].isOpen {
            return list[section].money.count + 1
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath)
            cell.textLabel?.text = list[indexPath.section].userName
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: moneyCellId, for: indexPath)
            cell.textLabel?.text = list[indexPath.section].money[indexPath.row-1]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if list[section].isOpen {
            if list[section].money[row-1] == "Add Money" {
                addMoney(section: section)
            } else {
                list[section].isOpen = false
                let indexes = IndexSet(integer: section)
                tableView.reloadSections(indexes, with: .automatic)
            }
        } else {
            if section == list.count - 1 {
                addUser()
            } else {
                list[section].isOpen = true
                let indexes = IndexSet(integer: section)
                tableView.reloadSections(indexes, with: .automatic)
            }
        }
    }
}
