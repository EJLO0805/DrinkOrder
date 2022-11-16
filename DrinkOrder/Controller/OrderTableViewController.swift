//
//  OrderTableViewController.swift
//  DrinkOrder
//
//  Created by 羅以捷 on 2022/11/8.
//

import UIKit

class OrderTableViewController: UITableViewController {
    
    var customerDetail : SelectedItemDetail = SelectedItemDetail()
    var items : [Item.Record] = [] //商品資料
    var itemsFormat : [(String, [Item.Record])] = [] //排序之後的商品資料，按照系列排序
    let date = Date()
    let current = Calendar.current
    
    @IBOutlet weak var customerNameTextField: UITextField! //輸入客戶名稱
    @IBOutlet weak var customerPhoneTextField: UITextField! //輸入電話資料
    @IBOutlet weak var categoryScrollView: UIScrollView! //系列ScrollView
    @IBOutlet weak var categoryStackView: UIStackView! //系列stackView
    @IBOutlet weak var categoryPage: UIPageControl! //系列Page
    @IBOutlet weak var itemPickerView: UIPickerView! //商品Pickerview
    @IBOutlet weak var itemNameLabel: UILabel! //商品名稱Label
    @IBOutlet weak var itemPriceLabel: UILabel! //商品價格Label
    @IBOutlet weak var iceSelectedSegment: UISegmentedControl! //選擇冰塊
    @IBOutlet weak var sugarSelectedSegment: UISegmentedControl! //選擇甜度
    @IBOutlet var addToppingSwitch: [UISwitch]! //加料switch
    @IBOutlet weak var totalPriceLabel: UILabel! //總共價格Label


    
    //將所有資料顯示到Label上
    func loadItemDetail(_ row: Int){
        let index = categoryPage.currentPage
        let itemDetial = itemsFormat[index].1[row].fields
        customerDetail.itemPrice = itemDetial.price
        itemPriceLabel.text = "飲料金額：\(customerDetail.itemPrice)元"
        totalPriceLabel.text = "總金額：\(customerDetail.totalPrice)元"
        itemNameLabel.text = "品項名稱：\(itemDetial.itemName)"
    }
    
    //將系列變成Label貼到StackView上
    func loadCategory(){
        if itemsFormat.count != 0{
            categoryPage.numberOfPages = itemsFormat.count
            for i in 0...itemsFormat.count-1{
                let itemLabel = UILabel()
                itemLabel.font = itemLabel.font.withSize(30)
                itemLabel.text = "\(itemsFormat[i].0)"
                itemLabel.textAlignment = .center
                categoryStackView.addArrangedSubview(itemLabel)
                if i == 0 {
                    itemLabel.widthAnchor.constraint(equalTo: categoryScrollView.frameLayoutGuide.widthAnchor).isActive = true
                }
            }
        }
    }
    
    //scrollView 與 pageControll 切換畫面的共同function
    func categoryChange(){
        itemPickerView.reloadAllComponents()
        itemPickerView.selectRow(0, inComponent: 0, animated: true)
        loadItemDetail(0)
        iceSelectedSegment.isHidden = itemsFormat[categoryPage.currentPage].0.contains("熱") ? true : false
    }
    
    //切換系列的Page Function
    @IBAction func categoryPageChange(_ sender: UIPageControl) {
        let index: Double = Double(sender.currentPage)
        categoryScrollView.setContentOffset(CGPoint(x: Double(categoryScrollView.bounds.width)*index, y: 0), animated: true)
        categoryChange()
    }
    
    //滑動系列讀取系列下商品以及位置歸零的Funtion
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == categoryScrollView {
            let index = Int(categoryScrollView.contentOffset.x/categoryScrollView.bounds.width)
            categoryPage.currentPage = index
            categoryChange()
        }
    }
    
    //主畫面更新
    func updateUI(with drinkItem: [Item.Record]){
        DispatchQueue.main.async {
            self.items = drinkItem
            let itemsDictionary = Dictionary(grouping: self.items){$0.fields.category}
            for var (key, values) in itemsDictionary {
                values.sort{$0.fields.itemName < $1.fields.itemName}
                self.itemsFormat.append((key, values))
            }
            self.itemsFormat.sort{$0.0 > $1.0 }
            self.loadCategory()
            self.loadItemDetail(0)
            self.itemPickerView.reloadAllComponents()
        }
    }
    
    //訂購成功提示
    func orderSuccess(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "訂購完成", message: "感謝您的訂購", preferredStyle: .alert)
            let successAlertAction = UIAlertAction(title: "OK", style: .default) {_ in
                self.customerNameTextField.text = ""
                self.customerPhoneTextField.text = ""
                self.customerDetail = SelectedItemDetail()
                for toppingSwitch in self.addToppingSwitch {
                    toppingSwitch.isOn = false
                }
                self.categoryPage.currentPage = 0
                self.iceSelectedSegment.selectedSegmentIndex = 0
                self.sugarSelectedSegment.selectedSegmentIndex = 0
                self.categoryScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.categoryChange()
                self.loadItemDetail(0)
            }
            alertController.addAction(successAlertAction)
            self.present(alertController, animated: true)
        }
    }
    
    //載入畫面
    override func viewDidLoad() {
        DataFetch().itemDataFetch { result in
            switch result {
                case .success(let drinkItems):
                    self.updateUI(with: drinkItems)
                case .failure(let error):
                    print(error)
            }
        }
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        customerNameTextField.delegate = self
        customerPhoneTextField.delegate = self
        itemPickerView.delegate = self
        itemPickerView.dataSource = self
        categoryScrollView.delegate = self
        categoryScrollView.showsHorizontalScrollIndicator = false
        super.viewDidLoad()
    }
    
    //加料Function
    @IBAction func addToppingPrice(_ sender: UISwitch) {
        switch sender.isOn{
            case true :
                customerDetail.toppingPrice += sender.tag
                let topping = ItemDetail().toppingItem[addToppingSwitch.firstIndex(of: sender)!]
                customerDetail.toppings?.append(topping)
            case false :
                let topping = ItemDetail().toppingItem[addToppingSwitch.firstIndex(of: sender)!]
                customerDetail.toppingPrice -= sender.tag
                customerDetail.toppings = customerDetail.toppings?.filter { !$0.contains(topping) }
        }
        totalPriceLabel.text = "總金額：\(customerDetail.totalPrice)元"
    }
    
    
    //確認訂購button
    @IBAction func confirmButton(_ sender: Any) {
        let month = current.component(.month, from: date)
        customerDetail.customerName = customerNameTextField.text!
        customerDetail.customerPhone = customerPhoneTextField.text!
        let alertController = UIAlertController(title: "資料錯誤", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel)
        let selectedItemForm = itemsFormat[categoryPage.currentPage].1[itemPickerView.selectedRow(inComponent: 0)].fields
        switch (customerDetail.customerName.isEmpty, customerDetail.customerPhone.isEmpty){
            case(true,true):
                alertController.message = "請輸入名字以及電話"
                alertController.addAction(alertAction)
                present(alertController, animated: true)
            case (true,_):
                alertController.message = "請輸入名字"
                alertController.addAction(alertAction)
                present(alertController, animated: true)
            case (_,true):
                alertController.message = "請輸入電話"
                alertController.addAction(alertAction)
                present(alertController, animated: true)
            case (false, false) where (selectedItemForm.isWinter == true && month < 11 && month > 2):
                if selectedItemForm.category.contains("熱"){
                    alertController.message = "目前不提供此飲品，請於11月至2月時選購"
                    alertController.addAction(alertAction)
                    present(alertController, animated: true)
                }
            default:
                customerDetail.iceQty = selectedItemForm.category.contains("熱") ? "" : ItemDetail().iceQtyIndex[iceSelectedSegment.selectedSegmentIndex]
                customerDetail.sugarQty = ItemDetail().sugarQtyIndex[sugarSelectedSegment.selectedSegmentIndex]
                customerDetail.selectedItemName = selectedItemForm.itemName
                DataFetch().customerSelectedItemUpload(customerDetail) { result in
                    switch result {
                        case .success(_):
                            self.orderSuccess()
                        case .failure(let error):
                            print(error)
                    }
                }
        }
    }
    
    //按任意地方收鍵盤
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
}

//PickerView
extension OrderTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //選擇幾個picker component
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //顯示商品數量
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if itemsFormat.count != 0 {
            let index = categoryPage.currentPage
            return itemsFormat[index].1.count
        }
        return 0
    }
    
    //顯示商品名稱
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if itemsFormat.count != 0 {
            let index = categoryPage.currentPage
            return itemsFormat[index].1[row].fields.itemName
        }
        return nil
    }
    //選擇商品後顯示資料
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadItemDetail(row)
    }
    
}

//輸入客戶名字以及電話後 按return收鍵盤
extension OrderTableViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
