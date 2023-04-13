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
    
    var activeViewController: UIViewController?

    var healthInfoModel: HealthInfoModel?
    var userSettingsModel: UserSettingsModel?
    var aimModel: AimModel?
    var savedProducts: [SavedProducts]?
    
    var userInfoVM = UserInfoViewModel()
    var aim: Aim?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = Auth.auth().currentUser {
            fetchUserHealthInfo()
            fetchUserSettings()
            fetchAim()
            setupUI()
            tabBarView.layer.cornerRadius = 10
            
        }
        else {
            guard let welcomeVc = mainStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController else {return}
            welcomeVc.modalTransitionStyle = .crossDissolve
            welcomeVc.modalPresentationStyle = .fullScreen
            present(welcomeVc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = Auth.auth().currentUser {
            fetchUserHealthInfo()
            fetchUserSettings()
            fetchAim()
            setupUI()
            tabBarView.layer.cornerRadius = 10
            
        }
    }
    
    @IBAction func didTapTabBarButton(_ sender: UIButton) {
        let tag = sender.tag
           homeButton.tintColor = UIColor(named: "unpressedTabBarColor")
           searchButton.tintColor = UIColor(named: "unpressedTabBarColor")
           scanButton.tintColor = UIColor(named: "unpressedTabBarColor")
           savedButton.tintColor = UIColor(named: "unpressedTabBarColor")
           profileButton.tintColor = UIColor(named: "unpressedTabBarColor")

           var newViewController: UIViewController?
           
           switch tag {
           case 0:
               guard let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {return}
               let homeNavVc = UINavigationController(rootViewController: homeVC)
               newViewController = homeNavVc
               homeButton.tintColor = UIColor(named: "pressedTabBarColor")
           case 1:
               guard let searchVC = mainStoryboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {return}
               searchVC.customTabBar = self.tabBarView
               let searchNavVc = UINavigationController(rootViewController: searchVC)
               newViewController = searchNavVc
               searchButton.tintColor = UIColor(named: "pressedTabBarColor")
           case 2:
               guard let scanVC = mainStoryboard.instantiateViewController(withIdentifier: "ScanViewController") as? ScanViewController else {return}
               scanVC.healthInfoModel = healthInfoModel
               scanVC.customTabBar = tabBarView
               let scanNavVc = UINavigationController(rootViewController: scanVC)
               newViewController = scanNavVc
               scanButton.tintColor = UIColor(named: "pressedTabBarColor")
           case 3:
               guard let savedVC = mainStoryboard.instantiateViewController(withIdentifier: "SavedViewController") as? SavedViewController else {return}
               savedVC.healthInfoModel = self.healthInfoModel
               savedVC.customTabBar = self.tabBarView
               savedVC.savedProducts = self.savedProducts ?? []
               let savedNavVc = UINavigationController(rootViewController: savedVC)
               newViewController = savedNavVc
               savedButton.tintColor = UIColor(named: "pressedTabBarColor")
           case 4:
               guard let profileVC = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}
               profileVC.customTabBar = self.tabBarView
               profileVC.healthInfoModel = self.healthInfoModel
               profileVC.userSettingsModel = self.userSettingsModel
               profileVC.aimModel = self.aimModel
               let profileNavVc = UINavigationController(rootViewController: profileVC)
               newViewController = profileNavVc
               profileButton.tintColor = UIColor(named: "pressedTabBarColor")
           default:
               break
           }
           
           if let newVC = newViewController {
               switchActiveViewController(to: newVC)
           }
    }
    
    private func setupUI() {
        guard let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {return}
        let navVC = UINavigationController(rootViewController: homeVC)
        contentView.addSubview(navVC.view)
        addChild(navVC)
        navVC.view.frame = contentView.bounds
        navVC.didMove(toParent: self)
        homeButton.tintColor = UIColor(named: "pressedTabBarColor")
    }
    
    func fetchUserHealthInfo() {
        userInfoVM.fetchUserHealthInfo { userHealthInfoModel in
            self.healthInfoModel = userHealthInfoModel
        }
    }
    
    func fetchUserSettings() {
        userInfoVM.fetchUserSettings { userSettingsModel in
            self.userSettingsModel = userSettingsModel
        }
    }
    
    func fetchAim() {
        userInfoVM.fetchAim { aimModel in
            self.aimModel = aimModel
        }
    }
    
    func fetchSavedProducts() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let savedProducts = appDelegate.fetchSavedProducts() {
            if !savedProducts.isEmpty {
                self.savedProducts = savedProducts
            }
        }
    }
    
    private func goHome() {
        var newViewController: UIViewController?
        guard let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {return}
        let homeNavVc = UINavigationController(rootViewController: homeVC)
        newViewController = homeNavVc
        homeButton.tintColor = UIColor(named: "pressedTabBarColor")
    }
    
    func switchActiveViewController(to newViewController: UIViewController) {
        if let activeVC = activeViewController {
            activeVC.willMove(toParent: nil)
            activeVC.view.removeFromSuperview()
            activeVC.removeFromParent()
        }
        
        addChild(newViewController)
        contentView.addSubview(newViewController.view)
        newViewController.view.frame = contentView.bounds
        newViewController.didMove(toParent: self)
        
        activeViewController = newViewController
    }
    
}
