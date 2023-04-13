//
//  ProfileViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData


class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var lastShopStackView: UIStackView!
    @IBOutlet weak var aimStackView: UIStackView!
    @IBOutlet weak var preferencesStackView: UIStackView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var healthyFoodLabel: UILabel!
    @IBOutlet weak var notRecommendedFoodLabel: UILabel!
    @IBOutlet weak var foodToAvoidLabel: UILabel!
    @IBOutlet weak var aboutUserLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var aimLabel: UILabel!
    
    private var mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
    
    var products: [Product] = []
    
    var customTabBar: UIView?
    
    var healthInfoModel: HealthInfoModel?
    var userSettingsModel: UserSettingsModel?
    var aimModel: AimModel?
    
    let userInfoVM = UserInfoViewModel()
    
    var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.makeRounded()
        displayUserHealthInfo()
        displayUserSettings()
        addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
        displayAim()
    }
    
    @IBAction func didTapEditButton(_ sender: UIBarButtonItem) {
        let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.customTabBar = self.customTabBar
        settingsVC.userSettingsModel = self.userSettingsModel
        settingsVC.profileImage = self.profileImage
        settingsVC.onSave = { [weak self] userSettingsModel in
            self?.userSettingsModel = userSettingsModel
            self?.displayUserSettings()
        }
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    private func addGestures() {
        let preferencesTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPreferencesSettings))
        preferencesStackView.addGestureRecognizer(preferencesTapGesture)
        
        let lastShopTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLastShopSettings))
        lastShopStackView.addGestureRecognizer(lastShopTapGesture)
        
        let aimTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAimSettings))
        aimStackView.addGestureRecognizer(aimTapGesture)
    }
    
    func displayUserHealthInfo() {
        healthyFoodLabel.text = healthInfoModel?.healthyFood?.joined(separator: ", ")
        notRecommendedFoodLabel.text = healthInfoModel?.notRecommendedFood?.joined(separator: ", ")
        foodToAvoidLabel.text = healthInfoModel?.foodToAvoid?.joined(separator: ", ")
    }
    
    func displayUserSettings() {
        
        aboutUserLabel.text = "\(userSettingsModel?.gender ?? ""), \(userSettingsModel?.age ?? 0) "
        userInfoVM.fetchProfileImage(from: userSettingsModel?.imageUrl ?? "gs://allergenie-a5ece.appspot.com", completion: {[weak self] image in
            self?.profileImageView.image = image ?? UIImage(named: "person.fill")
            self?.profileImage = image
        })
    }
    
    func displayAim() {
        if let aimModel = aimModel {
            aimLabel.text = aimModel.aimString
        } 
    }
    
    func showLoadingView() -> LoadingView {
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return loadingView
    }
    
    func fetchProducts() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let products = appDelegate.fetchProducts() {
            if !products.isEmpty {
                let itemsWord = products.count == 1 ? "item" : "items"
                dateLabel.text = "\(products.count) \(itemsWord) - \(products[0].productName ?? "not_found")"
            }
        }
    }
    
    //MARK: - @objc functions -
    @objc func didTapPreferencesSettings(_ gesture: UITapGestureRecognizer) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
        guard let healthInfoVC = mainStoryboard.instantiateViewController(withIdentifier: "HealthInfoViewController") as? HealthInfoViewController else {return}
        healthInfoVC.customTabBar = self.customTabBar
        healthInfoVC.healthInfoModel = self.healthInfoModel
        healthInfoVC.onSave = { [weak self] userhealthInfoModel in
            self?.healthInfoModel = userhealthInfoModel
            self?.displayUserHealthInfo()
        }
        navigationController?.pushViewController(healthInfoVC, animated: true)
    }
    
    @objc func didTapLastShopSettings(_ gesture: UITapGestureRecognizer) {
        let lastShopVC = LastShopViewController()
        lastShopVC.customTabBar = self.customTabBar
        lastShopVC.healthInfoModel = self.healthInfoModel
        lastShopVC.products = self.products
        navigationController?.pushViewController(lastShopVC, animated: true)
    }
    
    @objc func didTapAimSettings() {
        let aimVC = AimViewController()
        aimVC.customTabBar = self.customTabBar
        aimVC.aimModel = self.aimModel
        aimVC.onSave = { [weak self] aimModel in
            self?.aimModel = aimModel
            self?.displayAim()
        }
        navigationController?.pushViewController(aimVC, animated: true)
    }
}

