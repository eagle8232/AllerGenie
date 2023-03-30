//
//  ViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tabBarView.layer.cornerRadius = 10
        
    }
    
    private func setupUI() {
        
        guard let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {return}
        addChild(homeVC)
        contentView.addSubview(homeVC.view)
        homeVC.view.frame = contentView.bounds
        homeVC.didMove(toParent: self)
        homeButton.tintColor = UIColor(named: "pressedTabBarColor")
    }
    
    @IBAction func didTapTabBarButton(_ sender: UIButton) {
        let tag = sender.tag
        homeButton.tintColor = UIColor(named: "unpressedTabBarColor")
        searchButton.tintColor = UIColor(named: "unpressedTabBarColor")
        scanButton.tintColor = UIColor(named: "unpressedTabBarColor")
        savedButton.tintColor = UIColor(named: "unpressedTabBarColor")
        profileButton.tintColor = UIColor(named: "unpressedTabBarColor")
        
        switch tag {
        case 0:
            guard let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {return}
            addChild(homeVC)
            contentView.addSubview(homeVC.view)
            homeVC.view.frame = contentView.bounds
            homeVC.didMove(toParent: self)
            homeButton.tintColor = UIColor(named: "pressedTabBarColor")
        case 1:
            guard let searchVC = mainStoryboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {return}
            addChild(searchVC)
            contentView.addSubview(searchVC.view)
            searchVC.view.frame = contentView.bounds
            searchVC.didMove(toParent: self)
            searchButton.tintColor = UIColor(named: "pressedTabBarColor")
        case 2:
            guard let scanVC = mainStoryboard.instantiateViewController(withIdentifier: "ScanViewController") as? ScanViewController else {return}
            addChild(scanVC)
            contentView.addSubview(scanVC.view)
            scanVC.view.frame = contentView.bounds
            scanVC.didMove(toParent: self)
            scanButton.tintColor = UIColor(named: "pressedTabBarColor")
        case 3:
            guard let savedVC = mainStoryboard.instantiateViewController(withIdentifier: "SavedViewController") as? SavedViewController else {return}
            addChild(savedVC)
            contentView.addSubview(savedVC.view)
            savedVC.view.frame = contentView.bounds
            savedVC.didMove(toParent: self)
            savedButton.tintColor = UIColor(named: "pressedTabBarColor")
        case 4:
            guard let profileVC = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}
            let profileNavVc = UINavigationController(rootViewController: profileVC)
            addChild(profileNavVc)
            contentView.addSubview(profileNavVc.view)
            profileNavVc.view.frame = contentView.bounds
            profileNavVc.didMove(toParent: self)
            profileButton.tintColor = UIColor(named: "pressedTabBarColor")
        default:
            break
        }
        
    }
}



