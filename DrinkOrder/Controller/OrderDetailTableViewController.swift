//
//  OrderDetailTableViewController.swift
//  DrinkOrder
//
//  Created by 羅以捷 on 2022/11/8.
//

import UIKit

class OrderDetailTableViewController: UITableViewController {
    
    var customerSelectedDetail : [CustomerOrder.Record] = []
    
    func updateUI(with customerSelectedItem: [CustomerOrder.Record]){
        DispatchQueue.main.async {
            self.customerSelectedDetail = customerSelectedItem
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataFetch().customerSelectedOrderDownload { result in
            switch result {
                case .success(let customerSelectedItem):
                    self.updateUI(with: customerSelectedItem)
                case .failure(let error):
                    print("error\(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customerSelectedDetail.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderDetailCell", for: indexPath) as! OrderDetailTableViewCell
        cell.selectedItemName.text = "商品名稱"
        cell.customerPhone.text = "客戶電話"
        cell.customerName.text = "客戶名稱"
        cell.totalPrice.text = "總共金額"
        cell.detail.text = "備註"
        cell.customerPhoneLabel.text = customerSelectedDetail[indexPath.row].fields.customerPhone
        cell.selectedItemNameLabel.text = customerSelectedDetail[indexPath.row].fields.selectedItemName
        cell.customerNameLabel.text = customerSelectedDetail[indexPath.row].fields.customerName
        cell.totalPriceLabel.text = "\(customerSelectedDetail[indexPath.row].fields.totalPrice)元"
        cell.detailLabel.text = "\(customerSelectedDetail[indexPath.row].fields.sugarQty)"
        if customerSelectedDetail[indexPath.row].fields.iceQty != nil {
            cell.detailLabel.text! += "\(customerSelectedDetail[indexPath.row].fields.iceQty!)"
        }
        
        if customerSelectedDetail[indexPath.row].fields.toppings != nil{
            let toppings = customerSelectedDetail[indexPath.row].fields.toppings!
            cell.detailLabel.text! += " \( toppings.joined(separator: "、"))"
        }
        
        // Configure the cell...
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //刪除資料功能
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            let alertController = UIAlertController(title: "刪除訂單", message: "是否要刪除訂單", preferredStyle: .alert)
            let deleteAlertAction = UIAlertAction(title: "確認", style: .default) { action in
                DataFetch().customerSelectedItemDelete(self.customerSelectedDetail[indexPath.row].id!) { result in
                    switch result {
                        case .success(_):
                            self.customerSelectedDetail.remove(at: indexPath.row)
                            DispatchQueue.main.async {
                                self.tableView.deleteRows(at: [indexPath], with: .left)
                                self.tableView.reloadData()
                            }
                        case .failure(let error):
                            print(error)
                    }
                }
                
            }
            let cancelAlertAction = UIAlertAction(title: "取消", style: .cancel)
            alertController.addAction(deleteAlertAction)
            alertController.addAction(cancelAlertAction)
            self.present(alertController, animated: true)
            completionHandler(true)
        }
        
        //修改資料功能
        let reviseItems = UIContextualAction(style: .normal, title: "修改訂單") { action, view, completionHandler in
            if let reviseController = self.storyboard?.instantiateViewController(withIdentifier: "reviseItem") as? ReviseOrderTableViewController {
                reviseController.delegate = self
                reviseController.customerSelectedDetail.id = self.customerSelectedDetail[indexPath.row].id
                reviseController.customerSelectedDetail.customerName = self.customerSelectedDetail[indexPath.row].fields.customerName
                reviseController.customerSelectedDetail.customerPhone =  self.customerSelectedDetail[indexPath.row].fields.customerPhone
                reviseController.customerSelectedDetail.selectedItemName = self.customerSelectedDetail[indexPath.row].fields.selectedItemName
                reviseController.customerSelectedDetail.toppingPrice = self.customerSelectedDetail[indexPath.row].fields.toppingPrice
                reviseController.customerSelectedDetail.itemPrice = self.customerSelectedDetail[indexPath.row].fields.itemPrice
                reviseController.customerSelectedDetail.toppings = self.customerSelectedDetail[indexPath.row].fields.toppings
                reviseController.customerSelectedDetail.iceQty = self.customerSelectedDetail[indexPath.row].fields.iceQty
                reviseController.customerSelectedDetail.sugarQty = self.customerSelectedDetail[indexPath.row].fields.sugarQty
                self.present(reviseController, animated: true)
                completionHandler(true)
            }
            
        }
        
        //增加功能
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteItem, reviseItems])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


extension OrderDetailTableViewController: UpdateData {
    func updateData() {
        DataFetch().customerSelectedOrderDownload { result in
            switch result {
                case .success(let selectedItemArrey):
                    self.updateUI(with: selectedItemArrey)
                case .failure(let error):
                    print("error\(error)")
            }
        }
    }
}
