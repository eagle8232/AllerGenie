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
    
    let db = Firestore.firestore()

    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var healthyFoodTextField: UITextField!
    
    @IBOutlet weak var notRecommendedTextField: UITextField!
    
    @IBOutlet weak var avoidTextField: UITextField!
    
//    var healthyFood: [String]?
//    var notRecommendedFood: [String]?
//    var foodToAvoid: [String]?
    
    var healthInfoModel: HealthInfoModel?
    var userInfoViewModel = UserInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthyFoodTextField.delegate = self
        notRecommendedTextField.delegate = self
        avoidTextField.delegate = self
        displayUserHealthInfo()
    }
    
    @IBAction func didTapReturnButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        if let user = Auth.auth().currentUser {
            if let healthyText = healthyFoodTextField.text,
               let notRecommendedText = notRecommendedTextField.text,
               let foodToAvoidText = avoidTextField.text {
                let healthyFood = processTextFieldInput(healthyText)
                let notRecommendedFood = processTextFieldInput(notRecommendedText)
                let foodsToAvoid = processTextFieldInput(foodToAvoidText)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.saveUserHealthInfo(healthyFood: healthyFood, notRecommendedFood: notRecommendedFood, foodsToAvoid: foodsToAvoid)
                saveHealthInfoToFirestore(userId: user.uid, healthyFood: healthyFood, notRecommendedFood: notRecommendedFood, foodsToAvoid: foodsToAvoid)
            }
        } else {
            showNotification(message: "Sign in first", type: .error)
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
                self.showNotification(message: "Error occured", type: .error)
            } else {
                self.showNotification(message: "Health info saved successfully", type: .success)
            }
        }
    }

    func showNotification(message: String, type: NotificationType) {
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
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Hide the notification view after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                topConstraint.constant = -60
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    notificationView.removeFromSuperview()
                })
            }
        })
    }

    


}

extension HealthInfoViewController: UITextFieldDelegate {
    
}
