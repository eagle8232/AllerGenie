//
//  HomeViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/24/23.
//

import UIKit
import CoreData
import Kingfisher

class HomeViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var recentTableView: UITableView!
    
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
        recentTableView.delegate = self
        recentTableView.dataSource = self
        recentTableView.register(RecentTableViewCell.nib(), forCellReuseIdentifier: RecentTableViewCell.identifier)
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

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentTableViewCell.identifier, for: indexPath) as? RecentTableViewCell else {return UITableViewCell()}
        cell.brandNameLabel.text = filteredDataSource[indexPath.row].brandName
        cell.productImageView.kf.setImage(with: URL(string: filteredDataSource[indexPath.row].imageUrl ?? "")!)
        cell.productNameLabel.text = filteredDataSource[indexPath.row].productName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: UITextFieldDelegate {
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
        let filteredDataForBrandName: [Product]
        let filteredDataForProductName: [Product]

        if searchText.isEmpty {
            filteredDataForBrandName = products
            filteredDataForProductName = products
        } else {
            filteredDataForBrandName = products.filter { item in
                return item.brandName!.lowercased().contains(searchText.lowercased())
            }
            filteredDataForProductName = products.filter { item in
                return item.productName!.lowercased().contains(searchText.lowercased())
            }
        }

        if !filteredDataForBrandName.isEmpty {
            filteredDataSource = filteredDataForBrandName
        } else {
            filteredDataSource = filteredDataForProductName
        }

        // Reload the table view with the updated data
        recentTableView.reloadData()
    }
}
