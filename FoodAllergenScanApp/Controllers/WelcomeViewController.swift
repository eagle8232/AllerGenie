//
//  WelcomeViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn


class WelcomeViewController: UIViewController {
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = Auth.auth().currentUser {
            let mainVc = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController")
            mainVc.modalPresentationStyle = .fullScreen
            present(mainVc, animated: true)
        }
        
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                guard let mainVc = self?.mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") else {return}
                mainVc.modalPresentationStyle = .fullScreen
                self?.present(mainVc, animated: true)
                print("signed in")
            }
        }
    }
    
    @IBAction func didTapForgotPassword(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapPrivacyButton(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapGoogleSignIn(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard error == nil else {
                print(error)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                guard let mainVc = self?.mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") else {return}
                mainVc.modalPresentationStyle = .fullScreen
                self?.present(mainVc, animated: true)
                print("signed in")
            }
        }
    }
}
