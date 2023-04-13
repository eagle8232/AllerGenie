//
//  GoodMatchView.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/8/23.
//

import Foundation
import UIKit

enum ProductHealthiness {
    case healthy
    case notRecommended
    case avoid
    case not_found
}

class MatchView: UIView {
    
    let nameLabel = UILabel()
    
    let healthRatingImageView = UIImageView()
    
    var ingredientName: String? {
        didSet {
            nameLabel.text = ingredientName
        }
    }
    
    var isGoodForHealth: Bool = true {
        didSet {
            healthRatingImageView.image = isGoodForHealth ? UIImage(named: "checkmark") : UIImage(named: "xmark")
            healthRatingImageView.tintColor = isGoodForHealth ? .green : .red
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up the checkmark image view
        
        healthRatingImageView.tintColor = .green
        healthRatingImageView.contentMode = .scaleAspectFit
        addSubview(healthRatingImageView)
        
        // Set up the name label
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .left
        addSubview(nameLabel)
        
        // Layout the subviews
        healthRatingImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            healthRatingImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            healthRatingImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            healthRatingImageView.widthAnchor.constraint(equalToConstant: 18),
            healthRatingImageView.heightAnchor.constraint(equalToConstant: 18),
            
            nameLabel.leadingAnchor.constraint(equalTo: healthRatingImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
