//
//  AllergenFood.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/26/23.
//

import Foundation

struct AllergenFood {
    let productName: String
    let brand: String
    let ingredients: String
}

enum Matched: String {
    case excellent = "Excellent match!"
    case average = "Average match!"
    case avoid = "Avoid!"
    case not_recognized = "Not recognized"
}
