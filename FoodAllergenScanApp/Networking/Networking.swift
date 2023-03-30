//
//  Networking.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/26/23.
//

import Foundation

protocol NetworkingDelegate {
    func didGetAllergenData(_ data: AllergenFood)
}

class Networking {
    
    var delegate: NetworkingDelegate?
    
    func fetchProductInfo(barcode: String, completion: @escaping (String?, String?, String?, String?) -> Void) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Request error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let product = json?["product"] as? [String: Any] {
                    let productName = product["product_name"] as? String
                    let brand = product["brands"] as? String
                    let ingredients = product["ingredients_text"] as? String
                    let imageUrl = product["image_url"] as? String
                    
                    DispatchQueue.main.async {
                        completion(productName, brand, ingredients, imageUrl)
                    }
                }
            } catch let jsonError {
                print("JSON parsing error: \(jsonError)")
            }
        }
        
        task.resume()
        
        
    }
}
