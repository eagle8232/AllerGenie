//
//  UserViewModel.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/29/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
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
    
    func fetchUserHealth(uid: String, completion: @escaping((HealthInfoModel?) -> Void)) {
        let appDelegate = AppDelegate()
        
        //Check user health info with core data
        if let healthInfo = appDelegate.fetchUserHealthInfo() {
            if let healthyFood = healthInfo.healthyFood as? [String],
               let notRecommendedFood = healthInfo.notRecommendedFood as? [String],
               let foodToAvoid = healthInfo.foodsToAvoid as? [String] {
                
                let healthInfoModel = HealthInfoModel(healthyFood: healthyFood, notRecommendedFood: notRecommendedFood, foodToAvoid: foodToAvoid)
                
                completion(healthInfoModel)
            }
        } else {
            fetchHealthInfoFromFirestore(userId: uid) {healthyFoods, notRecommendedFoods, foodsToAvoid in
                guard let healthyFoods = healthyFoods,
                      let notRecommendedFoods = notRecommendedFoods,
                      let foodsToAvoid = foodsToAvoid else {
                    completion(nil)
                    return
                }
                
                let healthInfoModel = HealthInfoModel(healthyFood: healthyFoods, notRecommendedFood: notRecommendedFoods, foodToAvoid: foodsToAvoid)
                completion(healthInfoModel)
            }
        }
        
    }
    
    func fetchUserSettings(uid: String, completion: @escaping((UserSettingsModel?) -> Void)) {
        let appDelegate = AppDelegate()
        
        if let userSettings = appDelegate.fetchUserSettings() {
            if let email = userSettings.email {
                let userSettingsModel = UserSettingsModel(name: userSettings.name, email: email, age: userSettings.age, gender: userSettings.gender, imageUrl: userSettings.profileImage)
                completion(userSettingsModel)
            }
        } else {
            db.collection("users").document(uid).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching user data: \(error)")
                } else if let document = document, document.exists {
                    // Parse the user data
                    let userData = document.data()
                    let name = userData?["name"] as? String
                    let email = userData?["email"] as? String ?? ""
                    let age = userData?["age"] as? Int ?? 0
                    let gender = userData?["gender"] as? String
                    let profileImageURL = userData?["profileImage"] as? String
                    
                    // Update the UI with the fetched data
                    let userSettingsModel = UserSettingsModel(name: name, email: email, age: Int32(age), gender: gender, imageUrl: profileImageURL)
                    completion(userSettingsModel)
                } else {
                    completion(nil)
                    print("Document does not exist")
                }
            }
        }
        
    }
    
    func fetchAim(uid: String, completion: @escaping ((AimModel?) -> Void)) {
        let appDelegate = AppDelegate()
        
        if let aim = appDelegate.fetchAim() {
            let aimModel = AimModel(aimString: aim.aimString ?? "")
            completion(aimModel)
        } else {
            db.collection("aimInfo").document(uid).getDocument { (document, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let document = document, document.exists {
                    let userData = document.data()
                    let aimString = userData?["aimString"] as? String
                    let aimModel = AimModel(aimString: aimString ?? "")
                    completion(aimModel)
                } else {
                    completion(nil)
                    print("Document does not exist")
                }
            }
        }
    }
    
    func uploadProfileImageToStorage(uid: String, image: UIImage, completion: @escaping (String?) -> Void) {
        
        // Convert the UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to data.")
            completion(nil)
            return
        }

        // Create a reference to the Firebase Storage location for the profile image
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")

        // Upload the profile image to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading profile image: \(error)")
                completion(nil)
            } else {
                // Get the download URL of the uploaded profile image
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting profile image download URL: \(error)")
                        completion(nil)
                    } else if let url = url {
                        completion(url.absoluteString)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    
    func fetchProfileImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching profile image: \(error)")
                completion(nil)
            } else if let data = data {
                let image = UIImage(data: data)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
   
    
    func fetchUserHealthInfo(completion: @escaping ((HealthInfoModel?) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            if let user = Auth.auth().currentUser {
                //Check user healt info with core data
                self?.fetchUserHealth(uid: user.uid) { userHealthInfo in
                    if let userHealthInfo = userHealthInfo {
                        completion(userHealthInfo)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func fetchUserSettings(completion: @escaping ((UserSettingsModel?) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            if let user = Auth.auth().currentUser {
                //Check user healt info with core data
                self?.fetchUserSettings(uid: user.uid) { userSettingsModel in
                    if let userSettingsModel = userSettingsModel {
                        completion(userSettingsModel)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    func fetchAim(completion: @escaping ((AimModel?) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            if let user = Auth.auth().currentUser {
                self?.fetchAim(uid: user.uid, completion: { aimModel in
                    if let aimModel = aimModel {
                        completion(aimModel)
                    } else {
                        completion(nil)
                    }
                })
            }
        }
    }
}
