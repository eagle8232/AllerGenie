//
//  LastShopViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/10/23.
//

import UIKit
import CoreData

class LastShopViewController: UIViewController {

    private var lastShopTableView = UITableView()
    
    var products: [Product] = []
    var healthInfoModel: HealthInfoModel?
    var customTabBar: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Last Shop"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        TabBarOptions.hideTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBarOptions.showTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    //MARK: - Functions -
    
    func setupNav() {
        
    }
    
    private func setupTableView() {
        view.addSubview(lastShopTableView)
        lastShopTableView.delegate = self
        lastShopTableView.dataSource = self
        lastShopTableView.register(ProductsTableViewCell.nib(), forCellReuseIdentifier: ProductsTableViewCell.identifier)
        lastShopTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lastShopTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            lastShopTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            lastShopTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            lastShopTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
        
        
    }
}
extension LastShopViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductsTableViewCell.identifier, for: indexPath) as? ProductsTableViewCell else {return UITableViewCell()}
        cell.brandNameLabel.text = products[indexPath.row].brandName
        cell.productNameLabel.text = products[indexPath.row].productName
        cell.productImageView.kf.setImage(with: URL(string: products[indexPath.row].imageUrl ?? "")!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let allergenFood = AllergenFood(productName: products[indexPath.row].productName ?? "not_found", brand: products[indexPath.row].brandName ?? "not_found", ingredients: products[indexPath.row].ingredients ?? "not_found")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let productInfo = storyboard.instantiateViewController(withIdentifier: "ProductsInfoViewController") as? ProductsInfoViewController else {return}
        productInfo.customTabBar = self.customTabBar
        productInfo.productImageUrl = URL(string: products[indexPath.row].imageUrl ?? "")!
        productInfo.allergenFood = allergenFood
        productInfo.healthInfoModel = healthInfoModel
        navigationController?.pushViewController(productInfo, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
