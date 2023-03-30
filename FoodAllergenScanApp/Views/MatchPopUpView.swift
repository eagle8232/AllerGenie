//
//  MatchView.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/24/23.
//

import UIKit

class MatchPopUpView: UIView {

    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var brandImageView: UIImageView!
    
    init(brandName: String, productName: String, brandImageString: String, frame: CGRect) {
        super.init(frame: frame)
        self.brandNameLabel.text = brandName
        self.productNameLabel.text = productName
        self.brandImageView.image = UIImage(named: brandImageString)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let viewFroXib = Bundle.main.loadNibNamed("MatchPopUpView", owner: self, options: nil)![0] as! UIView
        viewFroXib.frame = self.bounds
        viewFroXib.layer.cornerRadius = 15
        self.addSubview(viewFroXib)
    }
    
    @IBAction func didTapMoreDetailsButton(_ sender: UIButton) {
    }
}
