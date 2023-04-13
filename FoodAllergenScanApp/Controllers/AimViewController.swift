//
//  AimViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/10/23.
//

import UIKit


class AimViewController: UIViewController {
    
    private lazy var aimTextField = CustomTextField()
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = UIColor(named: "pressedTabBarColor")
        button.layer.cornerRadius = 10
        return button
    }()
    
    var aimModel: AimModel?
    
    var appDelegate = AppDelegate()
    
    var customTabBar: UIView?
    
    var onSave: ((AimModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        displayAim()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabBarOptions.hideTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBarOptions.showTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    func setupUI() {
        title = "Aim"
        view.addSubview(aimTextField)
        aimTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            aimTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            aimTextField.heightAnchor.constraint(equalToConstant: 35),
            aimTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            aimTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
            
        ])
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: aimTextField.bottomAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }
    
    func displayAim() {
        if let aimModel = aimModel, let aimString = aimModel.aimString {
            aimTextField.text = aimString
        }
    }
    
    func saveAim() {
        if let aimString = aimTextField.text {
            let aimModel = AimModel(aimString: aimString)
            appDelegate.saveAim(aimString)
            NotificationCenter.showNotification(message: "Successfully saved", type: .success, view: self.view)
            onSave?(aimModel)
        } else {
            NotificationCenter.showNotification(message: "Fill the field", type: .error, view: self.view)
        }
        aimTextField.resignFirstResponder()
    }
    
    
    //MARK: - @objc functions
    
    @objc func didTapSaveButton(){
        saveAim()
    }
    
}

extension AimViewController: UITextFieldDelegate {
    
}
