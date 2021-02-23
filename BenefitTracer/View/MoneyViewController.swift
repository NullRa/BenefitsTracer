//
//  MoneyViewController.swift
//  BenefitTracer
//
//  Created by Jay on 2021/2/21.
//

import UIKit

class MoneyViewController: UIViewController {
    @IBOutlet weak var moneyTableView: UITableView!
    @IBOutlet weak var circularLabel: UILabel!
    @IBOutlet weak var circularView: UIView!

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
        addCircular()
    }

    func initUI(){
        circularLabel.text = "Circular Progress Ring"
    }

    func bind(){

    }

    func addCircular(){
        //底層的圓環
        let circularPath = UIBezierPath(ovalIn: CGRect(x: 110, y: 20, width: 200, height: 200))
        let circularLayer = CAShapeLayer()
        circularLayer.path = circularPath.cgPath
        circularLayer.strokeColor = UIColor.gray.cgColor
        circularLayer.fillColor = UIColor.clear.cgColor
        circularLayer.lineWidth = 25

        let percentageCircularPath = UIBezierPath(arcCenter: CGPoint(x: 210, y: 120), radius: 100, startAngle: CGFloat.pi/180*270, endAngle: CGFloat.pi/180*360, clockwise: true)
        let percentageCircularLayer = CAShapeLayer()
        percentageCircularLayer.path = percentageCircularPath.cgPath
        percentageCircularLayer.strokeColor = UIColor.blue.cgColor
        percentageCircularLayer.fillColor = UIColor.clear.cgColor
        percentageCircularLayer.lineWidth = 25

        self.circularView.layer.addSublayer(circularLayer)
        self.circularView.layer.addSublayer(percentageCircularLayer)
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
