//
//  FormatViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
//

import UIKit
struct FormatData: Codable {
    let hand:Float
    let startPrice:Float
    let money:Float
}
class FormatViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var formatTableView: UITableView!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    
    var moneyList: [FormatData]!
    var totalMoney: Float {
        var totalMoney:Float = 0
        moneyList.forEach { (data) in
            totalMoney = totalMoney + data.money
        }
        return totalMoney
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        initUI()
    }
    
    func initUI(){
        addButton.setTitle("Add Data", for: .normal)
        setTotalMoneyLabel()
    }
    
    
    func bind(){
        formatTableView.delegate = self
        formatTableView.dataSource = self
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        if let data = loadDataFromUserDefaults() {
            moneyList = data
        } else {
            moneyList = []
        }
    }
    
    func countMoney(hand:Float,startPrice:Float) -> Float{
        return (hand * startPrice * 0.15 + hand * startPrice/2)
    }
    
    func setTotalMoneyLabel(){
        totalMoneyLabel.text = "$: \(totalMoney)"
    }
    
    @objc func addButtonAction(){
        let alert = UIAlertController(title: "Count", message: "Enter Data", preferredStyle: .alert)
        alert.addTextField { (handTextField) in
            handTextField.placeholder = "Enter Hand."
            handTextField.keyboardType = .numberPad
        }
        alert.addTextField { (priceTextField) in
            priceTextField.placeholder = "Enter Start Price"
            priceTextField.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let handTextField = (alert.textFields?.first)! as UITextField
            let hand = Float(handTextField.text!)!
            let priceTextField = alert.textFields![1] as UITextField
            guard let price = Float(priceTextField.text!) else {
                return
            }
            //FIXME
            let money = self.countMoney(hand: hand, startPrice: price)
            let formatData = FormatData(hand: hand, startPrice: price, money: money)
            self.moneyList.append(formatData)
            self.saveDataInUserDefaults(formatData:self.moneyList)
            self.formatTableView.reloadData()
            self.setTotalMoneyLabel()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 將自定義物件存入 UserDefaults
    /// - Parameter personalInformation: _
    func saveDataInUserDefaults(formatData: [FormatData]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(formatData) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "FormatData")
        }
    }

    /// 將存在 UserDefaults 的自定義物件取出
    /// - Parameter personalInformation: _
    func loadDataFromUserDefaults() -> [FormatData]? {
        let defaults = UserDefaults.standard
        
        if let savedPerson = defaults.object(forKey: "FormatData") as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode([FormatData].self, from: savedPerson) {
                print("loadedPerson: \(loadedPerson)")
                return loadedPerson
            }
            return nil
        }
        return nil
    }
}

extension FormatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moneyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "formatCell", for: indexPath)
        let data = moneyList[indexPath.row]
        cell.textLabel?.text = "Hand: \(data.hand), start price: \(data.startPrice), money: \(data.money)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            moneyList.remove(at: indexPath.row)
            tableView.reloadData()
            setTotalMoneyLabel()
            saveDataInUserDefaults(formatData:moneyList)
        }
    }

}
