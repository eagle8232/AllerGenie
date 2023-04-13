//
//  SavedViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit

class SavedViewController: UIViewController {

    private lazy var tableView = UITableView()
    
    var savedProducts = [SavedProducts]()
    var healthInfoModel: HealthInfoModel?
    var customTabBar: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Products"
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedProducts()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductsTableViewCell.nib(), forCellReuseIdentifier: ProductsTableViewCell.identifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
        print(savedProducts)
    }
    
    private func fetchSavedProducts() {
        let appDelegate = AppDelegate()
        if let savedProducts = appDelegate.fetchSavedProducts() {
            self.savedProducts = savedProducts
            tableView.reloadData()
        }
    }
}

extension SavedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductsTableViewCell.identifier, for: indexPath) as? ProductsTableViewCell else {return UITableViewCell()}
        cell.brandNameLabel.text = savedProducts[indexPath.row].brandName
        cell.productNameLabel.text = savedProducts[indexPath.row].productName
        cell.productImageView.kf.setImage(with: URL(string: savedProducts[indexPath.row].imageUrl ?? "")!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let allergenFood = AllergenFood(productName: savedProducts[indexPath.row].productName ?? "not_found", brand: savedProducts[indexPath.row].brandName ?? "not_found", ingredients: savedProducts[indexPath.row].ingredients ?? "not_found")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let productInfo = storyboard.instantiateViewController(withIdentifier: "ProductsInfoViewController") as? ProductsInfoViewController else {return}
        productInfo.customTabBar = self.customTabBar
        productInfo.productImageUrl = URL(string: savedProducts[indexPath.row].imageUrl ?? "")!
//        productInfo.allergenFood = allergenFood
        productInfo.healthInfoModel = healthInfoModel
//        navigationController?.pushViewController(productInfo, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
