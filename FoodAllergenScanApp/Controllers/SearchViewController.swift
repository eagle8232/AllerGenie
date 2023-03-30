//
//  SearchViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit
import CoreData
import Kingfisher

class SearchViewController: UIViewController {

    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var products: [Product] = []
    var filteredDataSource = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProducts()
        setupTableView()
        addGestures()
        searchTextField.delegate = self
    }
    
    //MARK: - Functions -
    private func setupTableView() {
        productsTableView.delegate = self
        productsTableView.dataSource = self
        productsTableView.register(ProductsTableViewCell.nib(), forCellReuseIdentifier: ProductsTableViewCell.identifier)
        filteredDataSource = products
    }
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapToResign))
        view.addGestureRecognizer(tapGesture)
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
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let productInfo = storyboard.instantiateViewController(withIdentifier: "ProductsInfoViewController") as? ProductsInfoViewController else {return}
        productInfo.modalPresentationStyle = .fullScreen
        present(productInfo, animated: true)
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
