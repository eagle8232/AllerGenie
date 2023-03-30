//
//  NotificationView.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/29/23.
//

import UIKit

import UIKit

enum NotificationType {
    case success
    case error
}

class NotificationView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let notificationType: NotificationType

    init(message: String, notificationType: NotificationType) {
        self.notificationType = notificationType
        super.init(frame: .zero)
        label.text = message
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = notificationType == .success ? UIColor.systemGreen : UIColor.systemRed
        layer.cornerRadius = 8
        clipsToBounds = true
        
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
