//
//  ProductsInfoViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import Kingfisher
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProductsInfoViewController: UIViewController {
    
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var percentageView: CirclePercentageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var firstChoiceImageView: UIImageView!
    @IBOutlet weak var secondChoiceImageView: UIImageView!
    @IBOutlet weak var thirdChoiceImageView: UIImageView!
    @IBOutlet weak var suggestionsView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var branNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var customTabBar: UIView?
    
    var userInfoVM = UserInfoViewModel()
    
    var healthInfoModel: HealthInfoModel?
    var allergenFood: AllergenFood?
    var savedProducts: SavedProducts?
    
    var barcode: String?
    var productImageUrl: URL?
    var productImageUrlString: String?
    
    let overviewView = OverviewView()
    let ingredientsView = IngredientsView()
    let betterChoiceView = BetterChoiceView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = allergenFood?.productName ?? "Product"
        setupUI()
        setupProductInfoViews()
//        findIngredientMatches(for: allergenFood?.ingredients, with: healthInfoModel)
        percentageView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkProduct()
        TabBarOptions.hideTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBarOptions.showTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    //MARK: - @IBActions -
    
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            overviewView.isHidden = false
            ingredientsView.isHidden = true
            betterChoiceView.isHidden = true
        case 1:
            overviewView.isHidden = true
            ingredientsView.isHidden = false
            betterChoiceView.isHidden = true
        case 2:
            overviewView.isHidden = true
            ingredientsView.isHidden = true
            betterChoiceView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        let appDelegate = AppDelegate()
        if let savedProducts = savedProducts {
            if savedProducts.barcode == self.barcode && !savedProducts.isSaved {
                appDelegate.saveSavedProduct(barcode: barcode ?? "not_found", imageUrl: productImageUrlString, productName: allergenFood?.productName, brandName: allergenFood?.brand, ingredients: allergenFood?.ingredients, date: Date(), isSaved: true)
                saveButton.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            } else {
                appDelegate.deleteElementFromSavedProduct(barcode: savedProducts.barcode ?? "")
                saveButton.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
            }
        } else {
            appDelegate.saveSavedProduct(barcode: barcode ?? "not_found", imageUrl: productImageUrlString, productName: allergenFood?.productName, brandName: allergenFood?.brand, ingredients: allergenFood?.ingredients, date: Date(), isSaved: true)
            saveButton.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
        
    }
    
    //MARK: - Functions -
    func setupUI() {
        branNameLabel.text = allergenFood?.brand
        productNameLabel.text = allergenFood?.productName
        if let url = URL(string: productImageUrlString ?? "") {
            productImageView.kf.setImage(with: url)
        }
        
        fetchUserHealthInfo()
        configureSuggestionLabel(productHealthiness: .avoid)
    }
    
    func setupProductInfoViews() {
        // Set up the views
        suggestionsView.addSubview(overviewView)
        suggestionsView.addSubview(ingredientsView)
        suggestionsView.addSubview(betterChoiceView)
        overviewView.translatesAutoresizingMaskIntoConstraints = false
        ingredientsView.translatesAutoresizingMaskIntoConstraints = false
        betterChoiceView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            overviewView.topAnchor.constraint(equalTo: suggestionsView.topAnchor),
            overviewView.bottomAnchor.constraint(equalTo: suggestionsView.bottomAnchor),
            overviewView.leadingAnchor.constraint(equalTo: suggestionsView.leadingAnchor),
            overviewView.trailingAnchor.constraint(equalTo: suggestionsView.trailingAnchor),
            
            ingredientsView.topAnchor.constraint(equalTo: suggestionsView.topAnchor),
            ingredientsView.bottomAnchor.constraint(equalTo: suggestionsView.bottomAnchor),
            ingredientsView.leadingAnchor.constraint(equalTo: suggestionsView.leadingAnchor),
            ingredientsView.trailingAnchor.constraint(equalTo: suggestionsView.trailingAnchor),
            
            betterChoiceView.topAnchor.constraint(equalTo: suggestionsView.topAnchor),
            betterChoiceView.bottomAnchor.constraint(equalTo: suggestionsView.bottomAnchor),
            betterChoiceView.leadingAnchor.constraint(equalTo: suggestionsView.leadingAnchor),
            betterChoiceView.trailingAnchor.constraint(equalTo: suggestionsView.trailingAnchor)
        ])
        
        // Hide the views
        overviewView.isHidden = false
        ingredientsView.isHidden = true
        betterChoiceView.isHidden = true
        
        overviewView.healthInfo = healthInfoModel
        overviewView.ingredientsString = allergenFood?.ingredients
        ingredientsView.ingredients = allergenFood?.ingredients
    }
    
    func configureSuggestionLabel(productHealthiness: ProductHealthiness) {
        
        switch productHealthiness {
        case .healthy:
            suggestionLabel.text = "Healthy"
            suggestionLabel.textColor = .green
        case .notRecommended:
            suggestionLabel.text = "Not recommended"
            suggestionLabel.textColor = .yellow
        case .avoid:
            suggestionLabel.text = "Avoid"
            suggestionLabel.textColor = .red
        case .not_found:
            suggestionLabel.text = "Not found"
            suggestionLabel.textColor = .gray
        }
    }
    
    func fetchUserHealthInfo() {
        if let user = Auth.auth().currentUser {
            //Check user healt info with core data
            userInfoVM.fetchUserHealth(uid: user.uid) { [weak self] userHealthInfo in
                self?.healthInfoModel = HealthInfoModel(healthyFood: userHealthInfo?.healthyFood, notRecommendedFood: userHealthInfo?.notRecommendedFood, foodToAvoid: userHealthInfo?.foodToAvoid)
            }
        }
    }
    
    func saveToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let product = SavedProducts(context: context)
        product.productName = allergenFood?.productName
        product.brandName = allergenFood?.brand
        product.ingredients = allergenFood?.ingredients
        product.imageUrl = productImageUrlString
        
        do {
            try context.save()
        } catch {
            print("Failed saving to Core Data: \(error)")
        }
    }

    func saveToFirestore() {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        
        guard let uid = user?.uid else {
            return
        }
        
        let productRef = db.collection("users").document(uid).collection("products").document()
        
        let productData: [String: Any] = [
            "name": allergenFood?.productName ?? "",
            "brand": allergenFood?.brand ?? "",
            "ingredients": allergenFood?.ingredients ?? "",
            "imageUrlString": productImageUrlString ?? ""
        ]
        
        productRef.setData(productData) { error in
            if let error = error {
                print("Failed saving to Firestore: \(error)")
            } else {
                print("Product saved to Firestore")
            }
        }
    }

    
    func checkProduct() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        guard let ingredients = allergenFood?.ingredients,
              let healthyFoods = healthInfoModel?.healthyFood,
              let notRecommendedFoods = healthInfoModel?.notRecommendedFood,
              let foodsToAvoid = healthInfoModel?.foodToAvoid else { return }
        
        let ingredientsSet: Set<String> = Set(ingredients.map { ingredient in
            // Check for variations of the same food item
            switch ingredient.lowercased() {
            case "sugar", "honey", "brown sugar", "fructose":
                return "Added Sugar"
            case "salt", "sodium chloride":
                return "Salt"
            // add other variations and standard names here
            default:
                return String(ingredient)
            }
        })
        
        print(ingredientsSet)
        
        let healthyIntersection = ingredientsSet.intersection(healthyFoods)
        let notRecommendedIntersection = ingredientsSet.intersection(notRecommendedFoods)
        let foodsToAvoidIntersection = ingredientsSet.intersection(foodsToAvoid)
        
        let totalFoods = healthyIntersection.count + notRecommendedIntersection.count
        let healthyPercentage = Double(healthyIntersection.count) / Double(totalFoods) * 100
        
        let backgroundColor = getBackgroundColor(healthyIntersection: healthyIntersection,
                                                  notRecommendedIntersection: notRecommendedIntersection,
                                                  foodsToAvoidIntersection: foodsToAvoidIntersection,
                                                  healthyPercentage: healthyPercentage)
        // Set the background color
        view.backgroundColor = backgroundColor
        backgroundView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor
        appearance.backgroundColor = backgroundColor
        
        // Apply the appearance to the current navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
        
    private func getBackgroundColor(healthyIntersection: Set<String>,
                                     notRecommendedIntersection: Set<String>,
                                     foodsToAvoidIntersection: Set<String>,
                                     healthyPercentage: Double) -> UIColor {
        
        if !foodsToAvoidIntersection.isEmpty {
            return .red
        } else if !healthyIntersection.isEmpty && !notRecommendedIntersection.isEmpty {
            if healthyPercentage >= 70 {
                return .green
            } else {
                return UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            }
        } else if !healthyIntersection.isEmpty {
            return .green
        } else if !notRecommendedIntersection.isEmpty {
            return UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
        } else {
            return .gray
        }
    }
    
    func findIngredientMatches(for ingredients: [String], with userHealthInfo: HealthInfoModel) -> (healthy: [String], notRecommended: [String], toAvoid: [String], mixed: [String: Float]) {
        var healthyIngredients: [String] = []
        var notRecommendedIngredients: [String] = []
        var toAvoidIngredients: [String] = []
        var mixedIngredients: [String: Float] = [:]
        
        for ingredient in ingredients {
            
            // Split the user's health information into individual words
            let healthyWords = userHealthInfo.healthyFood?.flatMap { $0.components(separatedBy: " ") } ?? []
            let notRecommendedWords = userHealthInfo.notRecommendedFood?.flatMap { $0.components(separatedBy: " ") } ?? []
            let toAvoidWords = userHealthInfo.foodToAvoid?.flatMap { $0.components(separatedBy: " ") } ?? []
            
            // Check for exact matches
            if userHealthInfo.healthyFood?.contains(ingredient) == true {
                healthyIngredients.append(ingredient)
            } else if userHealthInfo.notRecommendedFood?.contains(ingredient) == true {
                notRecommendedIngredients.append(ingredient)
            } else if userHealthInfo.foodToAvoid?.contains(ingredient) == true {
                toAvoidIngredients.append(ingredient)
                
                // Check for partial matches
            } else {
                let matches: [String] = [healthyWords, notRecommendedWords, toAvoidWords].flatMap { words -> [String] in
                    words.filter { ingredient.contains($0) }
                }
                if matches.count == 1 {
                    switch matches[0] {
                    case let food where userHealthInfo.healthyFood?.contains(food) == true:
                        healthyIngredients.append(ingredient)
                    case let food where userHealthInfo.notRecommendedFood?.contains(food) == true:
                        notRecommendedIngredients.append(ingredient)
                    case let food where userHealthInfo.foodToAvoid?.contains(food) == true:
                        toAvoidIngredients.append(ingredient)
                    default:
                        break
                    }
                } else if matches.count == 2 {
                    let percentage: Float = Float(ingredients.count - matches.count) / Float(ingredients.count)
                    let mixedKey = "\(matches[0]) + \(matches[1])"
                    mixedIngredients[mixedKey] = percentage
                }
            }
        }
        
        return (healthy: healthyIngredients, notRecommended: notRecommendedIngredients, toAvoid: toAvoidIngredients, mixed: mixedIngredients)
    }
    
}

extension ProductsInfoViewController: CirclePercentageViewDelegate {
    func matchResult(_ result: ProductHealthiness) {
        configureSuggestionLabel(productHealthiness: result)
    }
}
