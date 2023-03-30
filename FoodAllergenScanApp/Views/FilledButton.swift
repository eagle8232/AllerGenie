//
//  FilledButton.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/29/23.
//

import UIKit

class FilledButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        if isHighlighted || isSelected {
            backgroundColor = .systemBlue.withAlphaComponent(0.7)
        } else {
            backgroundColor = .systemBlue
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .systemBlue
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 8
    }
    
    func TintColor() {
        
    }
}

