//
//  OverviewView.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/6/23.
//

import UIKit

class OverviewView: UIView {
    
    let stackView = UIStackView()
    let healthyStackView = UIStackView()
    let avoidStackView = UIStackView()
    
    var healthInfo: HealthInfoModel?
    
    var ingredientsString: String? {
        didSet {
            guard let ingredients = ingredientsString?.split(separator: ",") else {
                return
            }
            
            // Remove any existing subviews from the stack views
            healthyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            avoidStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // Create an ingredient view for each ingredient
            var healthyIngredientViews: [MatchView] = []
            var avoidIngredientViews: [MatchView] = []
            
            for ingredient in ingredients {
                let trimmedIngredient = String(ingredient).trimmingCharacters(in: .whitespaces)
                let view = MatchView()
                view.ingredientName = trimmedIngredient
                
                if isGoodForHealth(trimmedIngredient, healthyFoods: healthInfo?.healthyFood ?? [], notRecommendedFoods: healthInfo?.notRecommendedFood ?? [], foodsToAvoid: healthInfo?.foodToAvoid ?? []) {
                    view.isGoodForHealth = true
                    healthyIngredientViews.append(view)
                } else {
                    view.isGoodForHealth = false
                    avoidIngredientViews.append(view)
                }
            }
            
            // Add the healthy ingredient views to the healthy stack view
            healthyIngredientViews.forEach { healthyStackView.addArrangedSubview($0) }
            
            // Add the avoid ingredient views to the avoid stack view
            avoidIngredientViews.forEach { avoidStackView.addArrangedSubview($0) }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up the health rating image view
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        
        // Set up the healthy and avoid stack views
        healthyStackView.axis = .vertical
        healthyStackView.distribution = .fillEqually
        
        avoidStackView.axis = .vertical
        avoidStackView.distribution = .fillEqually
        
        stackView.addArrangedSubview(healthyStackView)
        stackView.addArrangedSubview(avoidStackView)
        
        // Layout the subviews
        stackView.translatesAutoresizingMaskIntoConstraints = false
        healthyStackView.translatesAutoresizingMaskIntoConstraints = false
        avoidStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            healthyStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5),
            avoidStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isGoodForHealth(_ ingredient: String, healthyFoods: [String], notRecommendedFoods: [String], foodsToAvoid: [String]) -> Bool {
        // Normalize the ingredient string
        let normalizedIngredient = ingredient.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Check if the ingredient is in the healthy foods list
        for healthyFood in healthyFoods {
            let normalizedHealthyFood = healthyFood.lowercased().trimmingCharacters(in: .whitespaces)
                if doStringsMatch(normalizedIngredient, normalizedHealthyFood) {
                    return true
                }
        }
        
        // Check if the ingredient is in the not recommended foods list
        for notRecommendedFood in notRecommendedFoods {
            let normalizedNotRecommendedFood = notRecommendedFood.lowercased().trimmingCharacters(in: .whitespaces)
                if doStringsMatch(normalizedIngredient, normalizedNotRecommendedFood) {
                    return false
                }
        }
        
        // Check if the ingredient is in the foods to avoid list
        for foodToAvoid in foodsToAvoid {
            let normalizedFoodToAvoid = foodToAvoid.lowercased().trimmingCharacters(in: .whitespaces)
                if doStringsMatch(normalizedIngredient, normalizedFoodToAvoid) {
                    return false
                }
        }
        
        // Ingredient is not in any of the lists
        return true
    }
    
    func doStringsMatch(_ string1: String, _ string2: String) -> Bool {
        let formattedString1 = string1.lowercased().replacingOccurrences(of: " ", with: "")
        let formattedString2 = string2.lowercased().replacingOccurrences(of: " ", with: "")
        
        return formattedString1.contains(formattedString2) || formattedString2.contains(formattedString1)
    }

}

