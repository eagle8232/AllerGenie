//
//  TabBarOptions.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/4/23.
//

import Foundation
import UIKit

class TabBarOptions {
    ///Hide tab bar
    static func hideTabBarAnimated(view: UIView, tabBar: UIView?, animated: Bool) {
        guard let tabBar = tabBar else { return }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                tabBar.frame.origin.y = UIScreen.main.bounds.height
            }
        } else {
            tabBar.frame.origin.y = UIScreen.main.bounds.height
        }
    }
    
    ///Show tab bar
    static func showTabBarAnimated(view: UIView, tabBar: UIView?, animated: Bool) {
        guard let tabBar = tabBar else { return }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                tabBar.frame.origin.y = UIScreen.main.bounds.height - tabBar.frame.height - view.safeAreaInsets.bottom - 10
            }
        } else {
            tabBar.frame.origin.y = UIScreen.main.bounds.height - tabBar.frame.height - view.safeAreaInsets.bottom - 10
        }
    }
}
