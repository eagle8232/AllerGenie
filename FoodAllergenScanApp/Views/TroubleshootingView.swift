//
//  InternetConnectionErrorView.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/11/23.
//

import UIKit
import Network

class TroubleshootingView: UIView {
    
    var action: (() -> Void)?
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "No internet connection"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.tintColor = .white
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        alpha = 0.8
        
        addSubview(errorLabel)
        addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            retryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleRetry() {
        action?()
    }
    
}
