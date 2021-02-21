//
//  ViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/20.
//

import UIKit

class UserViewController: UIViewController {

    let userCellId = "UserCell"

    var list = ["Add user"]

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
            self.list.insert(userName, at: self.list.count-1)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userTableView.dequeueReusableCell(withIdentifier: userCellId)!
        if let myLabel = cell.textLabel {
            myLabel.text = "\(list[indexPath.row])"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == (list.count-1) {
            addUser()
        }
    }
}
