//
//  IngredientsView.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/8/23.
//

import Foundation
import UIKit

class IngredientsView: UIView {
    
    var ingredientsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 20
        label.font = UIFont(name: "System", size: 17)
        return label
    }()
    
    var ingredients: String? {
        didSet {
            ingredientsLabel.text = ingredients
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(ingredientsLabel)
        ingredientsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ingredientsLabel.topAnchor.constraint(equalTo: topAnchor),
            ingredientsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            ingredientsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
}
