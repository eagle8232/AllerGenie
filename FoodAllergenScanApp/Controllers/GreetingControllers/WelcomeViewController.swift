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
import FBSDKLoginKit


class WelcomeViewController: UIViewController {
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var loginManager = LoginManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            if EmailValidation.isValidEmail(email) {
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                    guard error == nil else {
                        NotificationCenter.showNotification(message: "\(error!.localizedDescription)", type: .error, view: self!.view)
                        return
                    }
                    guard let mainVc = self?.mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") else {return}
                    mainVc.modalPresentationStyle = .fullScreen
                    self?.present(mainVc, animated: true)
                    print("signed in")
                }
            } else {
                NotificationCenter.showNotification(message: "Email is invalid", type: .error, view: self.view)
            }
        }
    }
    
    @IBAction func didTapNewUser(_ sender: UIButton) {
        guard let mainVc = self.mainStoryboard.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController else {return}
        mainVc.modalPresentationStyle = .fullScreen
        present(mainVc, animated: true)
        print("signed in")
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
                print(error!)
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
                guard let mainVc = self?.mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
                mainVc.modalPresentationStyle = .fullScreen
                self?.present(mainVc, animated: true)
                print("signed in")
            }
        }
    }
    
    @IBAction func didTapFacebookSignIn(_ sender: UIButton) {
        
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Error logging in with Facebook: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error signing in with Firebase using Facebook credential: \(error.localizedDescription)")
                    return
                }
                
                print("Successfully signed in with Firebase using Facebook credential")
                // Navigate to the next view controller
            }
        }
    }
}

extension WelcomeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the full text of the email text field.
        guard let emailText = textField.text else { return true }
        // Combine the old and new text to get the updated text.
        let updatedText = (emailText as NSString).replacingCharacters(in: range, with: string)
        // Validate the updated email text.
        if EmailValidation.isValidEmail(updatedText) {
            
            return true
        } else {
            // The email is invalid.
            // You can disable the login or registration button if it's enabled.
            // You can also display a warning message to the user.
            return false
        }
    }
}
