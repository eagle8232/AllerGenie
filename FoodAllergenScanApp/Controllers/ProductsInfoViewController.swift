//
//  ProductsInfoViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit

class ProductsInfoViewController: UIViewController {

    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var firstChoiceImageView: UIImageView!
    @IBOutlet weak var secondChoiceImageView: UIImageView!
    @IBOutlet weak var thirdChoiceImageView: UIImageView!
    @IBOutlet weak var suggestionsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func didChangeSuggestionsView(_ sender: UISegmentedControl) {
    }
    @IBAction func didTapReturnButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
