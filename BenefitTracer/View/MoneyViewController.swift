//
//  MoneyViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
//

import UIKit

class MoneyViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navVC = self.tabBarController?.viewControllers?[0] as? UINavigationController,
           let first = navVC.viewControllers[0] as? UserViewController{
            self.title = "Total Money: \(first.userViewModel.getTotalMoney())"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
        // Do any additional setup after loading the view.
    }

    func initUI(){

    }

    func bind(){

    }
    

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
