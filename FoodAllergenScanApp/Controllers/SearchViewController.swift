//
//  SearchViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit
import FirebaseAuth
import CoreData
import Kingfisher

class SearchViewController: UIViewController {

    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var customTabBar: UIView?
    
    var healthInfoModel: HealthInfoModel?
    var userInfoVM = UserInfoViewModel()
    
    var products: [Product] = []
    var filteredDataSource = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Specific Allergens"
        setupKeyboard()
        fecthUserlHealthInfo()
        fetchProducts()
        setupTableView()
        addGestures()
        searchTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //MARK: - Functions -
    
    func setupKeyboard() {
        // Create a toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        // Create a "Done" button for the toolbar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapToResign))
        toolbar.setItems([doneButton], animated: true)

        // Set the toolbar as the text field's accessory view
        searchTextField.inputAccessoryView = toolbar

    }
    
    private func setupTableView() {
        productsTableView.delegate = self
        productsTableView.dataSource = self
        productsTableView.register(ProductsTableViewCell.nib(), forCellReuseIdentifier: ProductsTableViewCell.identifier)
        filteredDataSource = products
    }
    
    private func addGestures() {
        
    }
    
    func fecthUserlHealthInfo() {
        DispatchQueue.main.async { [weak self] in
            if let user = Auth.auth().currentUser {
                //Check user healt info with core data
                self?.userInfoVM.fetchUserHealth(uid: user.uid) { [weak self] userHealthInfo in
                    let userHealthInfoModel = HealthInfoModel(healthyFood: userHealthInfo?.healthyFood, notRecommendedFood: userHealthInfo?.notRecommendedFood, foodToAvoid: userHealthInfo?.foodToAvoid)
                    self?.healthInfoModel = userHealthInfoModel
                }
            }
        }
    }
    
    func fetchProducts() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            products = try context.fetch(fetchRequest)
        } catch let error {
            print("Error fetching products: \(error.localizedDescription)")
        }
    }
    
    //MARK: - @objc functions -
    @objc func didTapToResign(_ gesture: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductsTableViewCell.identifier, for: indexPath) as? ProductsTableViewCell else {return UITableViewCell()}
        cell.brandNameLabel.text = filteredDataSource[indexPath.row].brandName
        cell.productNameLabel.text = filteredDataSource[indexPath.row].productName
        cell.productImageView.kf.setImage(with: URL(string: filteredDataSource[indexPath.row].imageUrl ?? "")!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let allergenFood = AllergenFood(productName: filteredDataSource[indexPath.row].productName ?? "not_found", brand: filteredDataSource[indexPath.row].brandName ?? "not_found", ingredients: filteredDataSource[indexPath.row].ingredients ?? "not_found")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let productInfo = storyboard.instantiateViewController(withIdentifier: "ProductsInfoViewController") as? ProductsInfoViewController else {return}
        productInfo.customTabBar = self.customTabBar
        productInfo.productImageUrlString = filteredDataSource[indexPath.row].imageUrl
        productInfo.allergenFood = allergenFood
        productInfo.healthInfoModel = healthInfoModel
        navigationController?.pushViewController(productInfo, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let text = textField.text else {
            return false
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let searchText = textField.text ?? ""

        // Assuming your original data source is an array of strings named 'dataArray'
        let ingredients: [Product]
        

        if searchText.isEmpty {
            ingredients = products
        } else {
            ingredients = products.filter { item in
                return item.ingredients!.lowercased().contains(searchText.lowercased())
            }
            
        }

        filteredDataSource = ingredients

        // Reload the table view with the updated data
        productsTableView.reloadData()
    }
}
