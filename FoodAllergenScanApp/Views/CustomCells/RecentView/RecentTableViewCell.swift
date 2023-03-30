//
//  RecentTableViewCell.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/24/23.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    static let identifier = "recentCell"
    
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    static func nib() -> UINib {
        let nib = UINib(nibName: "RecentTableViewCell", bundle: nil)
        return nib
    }
}
