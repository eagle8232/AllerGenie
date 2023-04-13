//
//  NotificationCenter.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/31/23.
//

import Foundation
import UIKit


class NotificationCenter {
    static func showNotification(message: String, type: NotificationType, view: UIView) {
        let notificationView = NotificationView(message: message, notificationType: type)
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(notificationView)
        
        // Set up initial constraints
        let topConstraint = notificationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -60)
        
        NSLayoutConstraint.activate([
            notificationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            notificationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            topConstraint,
            notificationView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        view.layoutIfNeeded()

        // Animate the notification view from the top
        topConstraint.constant = 20
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            view.layoutIfNeeded()
        }, completion: { _ in
            // Hide the notification view after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                topConstraint.constant = -60
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    view.layoutIfNeeded()
                }, completion: { _ in
                    notificationView.removeFromSuperview()
                })
            }
        })
    }

}
