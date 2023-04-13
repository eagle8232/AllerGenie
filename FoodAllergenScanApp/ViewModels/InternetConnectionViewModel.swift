//
//  InternetViewModel.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/11/23.
//

import UIKit

class InternetConnectionViewModel {
    static func showNoConnectionView(view: UIView, completion: @escaping((Bool) -> Void)) {
        let troubleshootingView = TroubleshootingView()
        troubleshootingView.action = {
            // Handle the error here
        }
        completion(true)
//        view.addSubview(troubleshootingView)
//        troubleshootingView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            troubleshootingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            troubleshootingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            troubleshootingView.topAnchor.constraint(equalTo: view.topAnchor),
//            troubleshootingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
    }
}
