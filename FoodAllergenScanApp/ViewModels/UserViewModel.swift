//
//  UserViewModel.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/29/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

class UserInfoViewModel {
    let db = Firestore.firestore()
    
    func fetchHealthInfoFromFirestore(userId: String, completion: @escaping([String]?, [String]?, [String]?) -> Void) {
        db.collection("healthInfo").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching health info from Firestore: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                let healthyFood = document.get("healthyFood") as? [String] ?? []
                let notRecommendedFood = document.get("notRecommendedFood") as? [String] ?? []
                let foodsToAvoid = document.get("foodsToAvoid") as? [String] ?? []
                
                completion(healthyFood, notRecommendedFood, foodsToAvoid)
            } else {
                print("No health info found for user")
                completion(nil, nil, nil)
            }
        }
    }
}
