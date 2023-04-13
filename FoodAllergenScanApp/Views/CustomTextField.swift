//
//  CustomTextField.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/12/23.
//

import UIKit

class CustomTextField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    private let clearButton = UIButton(type: .custom)
    
    var onReturnKeyPress: (() -> Void)?
    var onTextChanged: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up the clear button
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        clearButton.tintColor = UIColor(named: "pressedTabBarColor")
        rightView = clearButton
        rightViewMode = .always
        placeholder = "Set your aim..."
        // Set up keyboard return key to dismiss keyboard
        self.returnKeyType = .done
        self.addTarget(self, action: #selector(onReturnKey), for: .editingDidEndOnExit)
        
        // Set up text change listener
        self.addTarget(self, action: #selector(onTextChangedHandler), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    @objc private func clearText() {
        self.text = ""
        onTextChangedHandler()
    }
    
    @objc private func onReturnKey() {
        onReturnKeyPress?()
    }
    
    @objc private func onTextChangedHandler() {
        guard let text = self.text else {
            return
        }
        
        if text.isEmpty {
            clearButton.isHidden = true
        } else {
            clearButton.isHidden = false
        }
        
        onTextChanged?(text)
    }
}

