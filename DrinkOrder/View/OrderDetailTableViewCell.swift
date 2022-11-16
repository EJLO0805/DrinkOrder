//
//  OrderDetailTableViewCell.swift
//  DrinkOrder
//
//  Created by 羅以捷 on 2022/11/10.
//

import UIKit

class OrderDetailTableViewCell: UITableViewCell {
    
    @IBOutlet var customerNameLabel : UILabel!
    @IBOutlet var customerPhoneLabel : UILabel!
    @IBOutlet var selectedItemNameLabel : UILabel!
    @IBOutlet var totalPriceLabel : UILabel!
    @IBOutlet var detailLabel : UILabel!
    @IBOutlet var customerName : UILabel!
    @IBOutlet var customerPhone : UILabel!
    @IBOutlet var selectedItemName : UILabel!
    @IBOutlet var totalPrice : UILabel!
    @IBOutlet var detail : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
