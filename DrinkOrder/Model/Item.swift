//
//  File.swift
//  DrinkOrder
//
//  Created by 羅以捷 on 2022/11/8.
//

import Foundation

struct Item: Decodable{
    var records : [Record]
    struct Record: Decodable{
        let fields : Fields
    }
    struct Fields: Decodable{
        var itemName: String
        var price: Int
        var category: String
        var isWinter: Bool?
    }
}

struct CustomerOrder: Codable{
    var records : [Record]
    struct Record: Codable{
        let fields : Fields
        let id : String?
    }
    struct Fields: Codable{
        var customerName : String
        var customerPhone : String
        var selectedItemName : String
        var totalPrice : Int
        var iceQty : String?
        var sugarQty : String
        var toppings : [String]?
        var toppingPrice : Int
        var itemPrice : Int
    }
}

struct ItemDetail{
    let iceQtyIndex : [String] = ["完全去冰", "去冰", "微冰", "少冰", "正常冰"]
    let sugarQtyIndex : [String] = ["無糖", "微糖", "半糖", "少糖", "正常甜度"]
    let toppingItem = ["珍珠", "布丁", "椰果", "仙草凍", "粉角", "ＱＱ", "太極", "多多", "話梅", "香草冰淇淋"]
}

struct SelectedItemDetail{
    var totalPrice: Int {
        toppingPrice + itemPrice
    }
    var toppingPrice: Int = 0
    var itemPrice: Int = 0
    var toppings : [String]? = []
    var customerName: String = ""
    var customerPhone: String = ""
    var selectedItemName : String = ""
    var sugarQty : String = ""
    var iceQty : String? = ""
    var id : String?
}

struct DataFetch{
    let itemUrl = URL(string: "https://api.airtable.com/v0/appQEqYxrrVqgKPEm/Items")!
    var id : String?
    let customerOrderUrl = URL(string: "https://api.airtable.com/v0/appjWCiyvOXAXRU5Z/customerInfo")!
    
    let apiKey = "Bearer \("Your API Key")"
    //下載商品資料
    func itemDataFetch(completion : @escaping (Result<[Item.Record], Error>) -> Void){
        let url = itemUrl
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        request.setValue("\(apiKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decorder = JSONDecoder()
                    let itemResponse = try decorder.decode(Item.self, from: data)
                    completion(.success(itemResponse.records))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    //上傳訂單資料
    func customerSelectedItemUpload(_ customerDetail: SelectedItemDetail, completion: @escaping (Result<String, Error>) -> Void){
        let customerSelectedItemDetail : CustomerOrder.Record = CustomerOrder.Record(fields: CustomerOrder.Fields(customerName: customerDetail.customerName, customerPhone: customerDetail.customerPhone, selectedItemName: customerDetail.selectedItemName, totalPrice: customerDetail.totalPrice, iceQty: customerDetail.iceQty, sugarQty: customerDetail.sugarQty, toppings: customerDetail.toppings, toppingPrice: customerDetail.toppingPrice, itemPrice: customerDetail.itemPrice), id: nil)
        let url = DataFetch().customerOrderUrl
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(DataFetch().apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(customerSelectedItemDetail)
            URLSession.shared.uploadTask(with: request, from: data){ (data, response, error) in
                if let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil {
                    completion(.success("成功"))
                } else if error != nil {
                    completion(.failure(error!))
                }
            }.resume()
        } catch {
            print(completion(.failure(error)))
        }
    }
    
    //下載訂單List
    func customerSelectedOrderDownload(completion: @escaping (Result<[CustomerOrder.Record], Error>) -> Void){
        let url = customerOrderUrl
        var request = URLRequest(url: url)
        request.setValue("\(DataFetch().apiKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let customerSelectedItem = try decoder.decode(CustomerOrder.self, from: data)
                    completion(.success(customerSelectedItem.records))
                }catch{
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
    
    //刪除訂單
    func customerSelectedItemDelete(_ id: String, completion: @escaping(Result<String, Error>) -> Void){
        let url = customerOrderUrl.appendingPathComponent(id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("\(DataFetch().apiKey)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    completion(.success("success"))
            }else if error != nil{
                completion(.failure(error!))
            }
        }.resume()
    }
    
    //修改訂單
    func customerSelectedItemRevise(_ customerDetail: SelectedItemDetail, completion: @escaping (Result<String, Error>) -> Void){
        let customerSelectedItemDetail : CustomerOrder.Record = CustomerOrder.Record(fields: CustomerOrder.Fields(customerName: customerDetail.customerName, customerPhone: customerDetail.customerPhone, selectedItemName: customerDetail.selectedItemName, totalPrice: customerDetail.totalPrice, iceQty: customerDetail.iceQty, sugarQty: customerDetail.sugarQty, toppings: customerDetail.toppings, toppingPrice: customerDetail.toppingPrice, itemPrice: customerDetail.itemPrice), id: customerDetail.id)
        let url = DataFetch().customerOrderUrl
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("\(DataFetch().apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let updateOrder = CustomerOrder(records: [customerSelectedItemDetail])
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(updateOrder)
            URLSession.shared.dataTask(with: request){ (data, response, error) in
                if let data = data, let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else if error != nil {
                    completion(.failure(error!))
                }
            }.resume()
        }catch{
            print(completion(.failure(error)))
        }
    }
    
}
