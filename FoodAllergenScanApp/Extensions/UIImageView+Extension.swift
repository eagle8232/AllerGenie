//
//  UIImageView+Extension.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/3/23.
//

import UIKit

extension UIImageView {
    func makeRounded() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
    }
}

