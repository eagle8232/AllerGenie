//
//  HealthInfoViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/26/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData

class HealthInfoViewController: UIViewController {
    
    var onSave: ((HealthInfoModel) -> Void)?
    
    let db = Firestore.firestore()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var healthyFoodTextField: UITextField!
    
    @IBOutlet weak var notRecommendedTextField: UITextField!
    
    @IBOutlet weak var avoidTextField: UITextField!
    
    var customTabBar: UIView?
    
//    var healthyFood: [String]?
//    var notRecommendedFood: [String]?
//    var foodToAvoid: [String]?
    
    var userInfoVM = UserInfoViewModel()
    var healthInfoModel: HealthInfoModel?
    var userInfoViewModel = UserInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Health Info"
        healthyFoodTextField.delegate = self
        notRecommendedTextField.delegate = self
        avoidTextField.delegate = self
        displayUserHealthInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabBarOptions.hideTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBarOptions.showTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }

    @IBAction func didTapSaveButton(_ sender: UIButton) {
        if let user = Auth.auth().currentUser {
            if let healthyText = healthyFoodTextField.text,
               let notRecommendedText = notRecommendedTextField.text,
               let foodToAvoidText = avoidTextField.text {
                let healthyFood = processTextFieldInput(healthyText)
                let notRecommendedFood = processTextFieldInput(notRecommendedText)
                let foodsToAvoid = processTextFieldInput(foodToAvoidText)
                
                let userHealthInfoModel = HealthInfoModel(healthyFood: healthyFood, notRecommendedFood: notRecommendedFood, foodToAvoid: foodsToAvoid)
                self.appDelegate.saveUserHealthInfo(healthyFood: healthyFood, notRecommendedFood: notRecommendedFood, foodsToAvoid: foodsToAvoid)
                saveHealthInfoToFirestore(userId: user.uid, healthyFood: healthyFood, notRecommendedFood: notRecommendedFood, foodsToAvoid: foodsToAvoid)
                
                self.onSave?(userHealthInfoModel)
            }
        } else {
            NotificationCenter.showNotification(message: "Sign in first", type: .error, view: self.view)
        }
        healthyFoodTextField.resignFirstResponder()
        notRecommendedTextField.resignFirstResponder()
        avoidTextField.resignFirstResponder()
    }

    func displayUserHealthInfo() {
        if let user = Auth.auth().currentUser {
            if let healthyFood = healthInfoModel?.healthyFood,
               let notRecommendedFood = healthInfoModel?.notRecommendedFood,
               let foodToAvoid = healthInfoModel?.foodToAvoid {
                healthyFoodTextField.text = healthyFood.joined(separator: ", ")
                notRecommendedTextField.text = notRecommendedFood.joined(separator: ", ")
                avoidTextField.text = foodToAvoid.joined(separator: ", ")
            } else {
                userInfoViewModel.fetchHealthInfoFromFirestore(userId: user.uid) { healthyFood, notRecommendedFood, foodToAvoid in
                    self.healthyFoodTextField.text = healthyFood?.joined(separator: ", ")
                    self.notRecommendedTextField.text = notRecommendedFood?.joined(separator: ", ")
                    self.avoidTextField.text = foodToAvoid?.joined(separator: ", ")
                }
            }
        }
    }
    
    func processTextFieldInput(_ input: String) -> [String] {
        return input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    func saveHealthInfoToFirestore(userId: String, healthyFood: [String], notRecommendedFood: [String], foodsToAvoid: [String]) {
        db.collection("healthInfo").document(userId).setData([
            "healthyFood": healthyFood,
            "notRecommendedFood": notRecommendedFood,
            "foodsToAvoid": foodsToAvoid
        ]) { error in
            if let error = error {
                print("Error saving health info to Firestore: \(error.localizedDescription)")
                NotificationCenter.showNotification(message: "Error occured", type: .error, view: self.view)
            } else {
                NotificationCenter.showNotification(message: "Health info saved successfully", type: .success, view: self.view)
            }
        }
    }
}

extension HealthInfoViewController: UITextFieldDelegate {
    
}
