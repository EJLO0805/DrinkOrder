//
//  ReviseOrderTableViewController.swift
//  DrinkOrder
//
//  Created by 羅以捷 on 2022/11/15.
//

import UIKit

class ReviseOrderTableViewController: UITableViewController {
    
    var customerSelectedDetail : SelectedItemDetail = SelectedItemDetail()
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerPhoneLabel: UILabel!
    @IBOutlet weak var customerSelectedItemLabel: UILabel!
    @IBOutlet weak var customerSelectedItemPriceLabel: UILabel!
    @IBOutlet weak var customerSelectedIceQtySegement: UISegmentedControl!
    @IBOutlet weak var customerSelectedSugarQtySegment: UISegmentedControl!
    @IBOutlet var addToppingSwitch: [UISwitch]!
    @IBOutlet weak var totalPriceLabel: UILabel!

    var delegate: UpdateData?

    override func viewDidLoad() {
        customerNameLabel.text = customerSelectedDetail.customerName
        customerPhoneLabel.text = customerSelectedDetail.customerPhone
        customerSelectedItemLabel.text = customerSelectedDetail.selectedItemName
        customerSelectedItemPriceLabel.text = "\(customerSelectedDetail.itemPrice)"
        totalPriceLabel.text = "\(customerSelectedDetail.totalPrice)"
        customerSelectedDetail.toppings = customerSelectedDetail.toppings == nil ? [] : customerSelectedDetail.toppings
        if let iceQty = customerSelectedDetail.iceQty {
            customerSelectedIceQtySegement.selectedSegmentIndex = ItemDetail().iceQtyIndex.firstIndex(of: iceQty)!
        } else {
            customerSelectedIceQtySegement.isHidden = true
        }
        customerSelectedSugarQtySegment.selectedSegmentIndex = ItemDetail().sugarQtyIndex.firstIndex(of: customerSelectedDetail.sugarQty)!
        guard let toppings = customerSelectedDetail.toppings else {return}
        for topping in toppings {
            let hadTopping = ItemDetail().toppingItem.contains(topping)
            switch hadTopping{
                case true:
                    let switchIndex = ItemDetail().toppingItem.firstIndex(of: topping)!
                    addToppingSwitch[switchIndex].isOn = true
                case false :
                    let switchIndex = ItemDetail().toppingItem.firstIndex(of: topping)!
                    addToppingSwitch[switchIndex].isOn = false
            }
        }
        super.viewDidLoad()
    }
    
    @IBAction func addtopping(_ sender: UISwitch) {
        switch sender.isOn {
            case true :
                customerSelectedDetail.toppingPrice += sender.tag
                let topping = ItemDetail().toppingItem[addToppingSwitch.firstIndex(of: sender)!]
                customerSelectedDetail.toppings?.append(topping)
            case false :
                let topping = ItemDetail().toppingItem[addToppingSwitch.firstIndex(of: sender)!]
                customerSelectedDetail.toppingPrice -= sender.tag
                customerSelectedDetail.toppings = customerSelectedDetail.toppings?.filter { !$0.contains(topping) }
        }
        totalPriceLabel.text = "總金額：\(customerSelectedDetail.totalPrice)元"
    }
    
    @IBAction func confirmButton(_ sender: Any) {
        customerSelectedDetail.iceQty = customerSelectedIceQtySegement.isHidden == false ? ItemDetail().iceQtyIndex[customerSelectedIceQtySegement.selectedSegmentIndex] : nil
        customerSelectedDetail.sugarQty = ItemDetail().sugarQtyIndex[customerSelectedSugarQtySegment.selectedSegmentIndex]
        let alertController = UIAlertController(title: "訂單修改", message: nil, preferredStyle: .alert)
        DataFetch().customerSelectedItemRevise(customerSelectedDetail) { result in
            switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        alertController.message = "成功"
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            self.delegate?.updateData()
                            self.dismiss(animated: true)
                        }))
                        self.present(alertController, animated: true)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        alertController.message = "失敗"
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alertController, animated: true){
                            print(error)
                        }
                    }
            }
        }
    }
}

protocol UpdateData {
    func updateData()
}
