//
//  BenefitsViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
//

import UIKit

class RealTimePriceViewController: UIViewController {
    let realTimePriceCellCellId = "realTimePriceCell"
    var itemList: [ItemData] = []
    let userRespository = UserRespository()
    //$:1000(+0%)
    //$:1300(+30%)
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var realTimePriceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        bind()
        initUI()
    }
    
    func initUI(){
        realTimePriceTableView.tableFooterView = UIView()
        totalMoneyLabel.text = "Total Money: \(getTotlePrice())"
        self.title = "Real Time Price"
    }
    
    func bind(){
        realTimePriceTableView.delegate = self
        realTimePriceTableView.dataSource = self
        setList()
    }
}

extension RealTimePriceViewController {
    func setList(){
        let itemDict = userRespository.queryItemCoreData()
        for (name,price) in itemDict {
            let itemData = ItemData(itemName: name, itemPrice: price)
            itemList.append(itemData)
        }
    }
    
    func getTotlePrice() -> Int {
        var totalPrice = 0
        itemList.forEach { (itemData) in
            totalPrice = totalPrice + itemData.itemPrice
        }
        return totalPrice
    }
}

extension RealTimePriceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: realTimePriceCellCellId, for: indexPath)
        cell.textLabel?.text = itemList[indexPath.row].itemName
        cell.detailTextLabel?.text = "\(itemList[indexPath.row].itemPrice)"
        return cell
    }
}
