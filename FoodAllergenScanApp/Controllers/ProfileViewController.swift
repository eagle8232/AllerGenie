//
//  ProfileViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


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
    
    private var mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
    
    var healthInfoModel: HealthInfoModel?
    
    let userInfoVM = UserInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayUserHealthInfo()
        addGestures()
    }
    
    
    @IBAction func didTapEditButton(_ sender: UIBarButtonItem) {
        
    }
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPreferencesSettings))
        preferencesStackView.addGestureRecognizer(tapGesture)
    }
    
    func displayUserHealthInfo() {
        DispatchQueue.main.async { [weak self] in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if let user = Auth.auth().currentUser {
                if let healthInfo = appDelegate.fetchUserHealthInfo() {
                    if let healthyFood = healthInfo.healthyFood as? [String],
                       let notRecommendedFood = healthInfo.notRecommendedFood as? [String],
                       let foodToAvoid = healthInfo.foodsToAvoid as? [String] {
                        self?.healthyFoodLabel.text = healthyFood.joined(separator: ", ")
                        self?.notRecommendedFoodLabel.text = notRecommendedFood.joined(separator: ", ")
                        self?.foodToAvoidLabel.text = foodToAvoid.joined(separator: ", ")
                        
                        let healthyFood = healthyFood
                        let notRecommendedFood = notRecommendedFood
                        let foodToAvoid = foodToAvoid
                        self?.healthInfoModel = HealthInfoModel(healthyFood: healthyFood, notRecommendedFood: notRecommendedFood, foodToAvoid: foodToAvoid)
                    }
                }
                else {
                    let loadingView = self?.showLoadingView()
                    self?.userInfoVM.fetchHealthInfoFromFirestore(userId: user.uid) {healthyFoods, notRecommendedFoods, foodsToAvoid in
                        self?.healthyFoodLabel.text = healthyFoods?.joined(separator: ", ")
                        self?.notRecommendedFoodLabel.text = notRecommendedFoods?.joined(separator: ", ")
                        self?.foodToAvoidLabel.text = foodsToAvoid?.joined(separator: ", ")
                        
                    }
                    DispatchQueue.main.async {
                        loadingView?.removeFromSuperview()
                    }
                }
            }
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

    
    @objc func didTapPreferencesSettings(_ gesture: UITapGestureRecognizer) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
        guard let healthInfoVC = mainStoryboard.instantiateViewController(withIdentifier: "HealthInfoViewController") as? HealthInfoViewController else {return}
        healthInfoVC.modalTransitionStyle = .crossDissolve
        healthInfoVC.modalPresentationStyle = .fullScreen
        healthInfoVC.healthInfoModel = self.healthInfoModel
        present(healthInfoVC, animated: true)
    }
}
