//
//  RegistrationViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/31/23.
//

import UIKit
import FirebaseAuth

class RegistrationViewController: UIViewController {
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapCreateAccountButton(_ sender: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            
            if isValidEmail(email) {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        NotificationCenter.showNotification(message: "\(error.localizedDescription)", type: .error, view: self.view)
                        print(error)
                    } else {
                        NotificationCenter.showNotification(message: "Succesfully created", type: .success, view: self.view)
                        guard let mainVc = self.mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
                        mainVc.modalPresentationStyle = .fullScreen
                        self.present(mainVc, animated: true)
                        print("signed in")
                    }
                    
                    print(result?.user.email)
                }
            } else {
                NotificationCenter.showNotification(message: "Email is invalid", type: .error, view: self.view)
            }
        }
    }
    
    @IBAction func didTapAlreadyHaveAccount(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    func isValidEmail(_ email: String) -> Bool {
        // Regular expression to validate email format.
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
