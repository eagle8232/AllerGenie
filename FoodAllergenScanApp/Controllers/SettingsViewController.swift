//
//  SettingsViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/3/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    let db = Firestore.firestore()
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    @IBOutlet weak var agePickerView: UIPickerView!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var userInfoVM = UserInfoViewModel()
    var userSettingsModel: UserSettingsModel?
    
    let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
    
    var customTabBar: UIView?
    
    var saveBarButton = UIBarButtonItem()
    
    let genderOptions = ["Male", "Female", "Other"]
    let ageOptions = Array(18...100)
    
    
    var profileImage: UIImage?
    var profileImageUrl: String?
    
    var onSave: ((UserSettingsModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupDelegates()
        
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displaySettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabBarOptions.hideTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBarOptions.showTabBarAnimated(view: self.view, tabBar: self.customTabBar, animated: true)
    }
    
    //MARK: - @IBActions -
    
    @IBAction func didTapLogOut(_ sender: UIButton) {
        let alertController = UIAlertController(title: "You are about to log out", message: "Are you sure to log out?", preferredStyle: .alert)
        let yesAC = UIAlertAction(title: "Yes", style: .default) { _ in
            self.logOut()
        }
        let noAc = UIAlertAction(title: "No", style: .cancel)
        alertController.addAction(yesAC)
        alertController.addAction(noAc)
        present(alertController, animated: true)
    }
    
    
    //MARK: - Functions -
    
    func displaySettings() {
        DispatchQueue.main.async { [weak self] in
            if let user = Auth.auth().currentUser {
                //Check user healt info with core data
                self?.userInfoVM.fetchProfileImage(from: self?.userSettingsModel?.imageUrl ?? "gs://allergenie-a5ece.appspot.com", completion: { image in
                    self?.profileImageView.image = image ?? UIImage(named: "person.fill")
                })
                self?.nameTextField.text = self?.userSettingsModel?.name
                self?.emailTextField.text = user.email
                let genderIndex = self?.genderOptions.firstIndex(of: self?.userSettingsModel?.gender ?? "Male") ?? 0
                self?.genderPickerView.selectRow(genderIndex, inComponent: 0, animated: true)
                
                let ageIndex = (self?.userSettingsModel?.age ?? 18) - 18
                print(ageIndex)
                self?.agePickerView.selectRow(Int(ageIndex), inComponent: 0, animated: true)
                self?.profileImageUrl = self?.userSettingsModel?.imageUrl
                self?.profileImageView.makeRounded()
            }
        }
    }
    
    func setupNav() {
        title = "Settings"
        saveBarButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        saveBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = saveBarButton
    }
    
    func setupDelegates() {
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        agePickerView.dataSource = self
        agePickerView.delegate = self
        nameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func selectedGender() -> String {
        let selectedIndex = genderPickerView.selectedRow(inComponent: 0)
        return genderOptions[selectedIndex]
    }

    func selectedAge() -> Int {
        let selectedIndex = agePickerView.selectedRow(inComponent: 0)
        return ageOptions[selectedIndex]
    }

    ///To set an image for profile view
    func presentImagePickerActionSheet() {
        let actionSheet = UIAlertController(title: "Choose a photo", message: nil, preferredStyle: .actionSheet)

        // Add the option to pick a photo from the photo library
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.presentImagePickerController(sourceType: .photoLibrary)
        }))

        // Add the option to take a photo using the camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.presentImagePickerController(sourceType: .camera)
            }))
        }

        // Add the cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Present the action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }

    func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }

    
    ///Save to Firestore
    func saveUserDataToFirestore(name: String, gender: String, age: Int, profileImageData: String) {
        // Ensure the user is logged in to get their UID
        let currentUser = Auth.auth().currentUser
        guard let currentUserUID = currentUser?.uid else {
            print("Error: No user is currently signed in.")
            return
        }

        // Prepare the data to be saved
        let userData: [String: Any] = [
            "name": name,
            "gender": gender,
            "age": age,
            "profileImage": profileImageData
        ]

        //If emailtextfield is changed, so save a new email
        if let email = emailTextField.text{
            if EmailValidation.isValidEmail(email) {
                currentUser?.updateEmail(to: email) { error in
                    if let error = error {
                        NotificationCenter.showNotification(message: "Error occurred: \(error.localizedDescription)", type: .error, view: self.view)
                        return
                    }
                }
                
                // Save the data to Firestore
                db.collection("users").document(currentUserUID).setData(userData) { error in
                    if let error = error {
                        print("Error writing user data: \(error)")
                        NotificationCenter.showNotification(message: "Error occurred: \(error.localizedDescription)", type: .error, view: self.view)
                    } else {
                        print("User data successfully written!")
                        NotificationCenter.showNotification(message: "Successfully saved!", type: .success, view: self.view)
                    }
                }
            } else {
                //Check if a new email is valid, if no, return, so save function couldn't be triggered
                NotificationCenter.showNotification(message: "Email is not valid", type: .error, view: self.view)
                return
            }
        }
        
    }


    ///Log out
    func logOut() {
        do {
            try Auth.auth().signOut()
            guard let welcomeVC = mainStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController else {return}
            welcomeVC.modalTransitionStyle = .crossDissolve
            welcomeVC.modalPresentationStyle = .fullScreen
            present(welcomeVC, animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            NotificationCenter.showNotification(message: "Error occurred: \(signOutError.localizedDescription)", type: .error, view: self.view)
        }
    }
    
    //MARK: - @objc functions -
    
    @objc func profileImageViewTapped(_ gesture: UITapGestureRecognizer) {
        presentImagePickerActionSheet()
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func didTapSaveButton(_ sender: UIBarButtonItem) {
        saveBarButton.isEnabled = false
        guard let email = emailTextField.text else {
            // Handle the error (e.g., display an alert to the user)
            return
        }
        guard let name = nameTextField.text, !name.isEmpty else {
            // Handle the error (e.g., display an alert to the user)
            return
        }
        
        // Get the selected gender and age from the picker views
        let gender = selectedGender()
        let age = selectedAge()
        
        let userSettingsModel = UserSettingsModel(name: name, email: email, age: Int32(age), gender: gender, imageUrl: profileImageUrl)
        // Save the data to Firestore
        saveUserDataToFirestore(name: name, gender: gender, age: age, profileImageData: profileImageUrl ?? "")
        appDelegate.saveUserSettings(name: name, email: email, age: Int32(age), gender: gender, profileImageUrl: profileImageUrl)
        onSave?(userSettingsModel)
    }
    
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource -

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 { // Assuming tag 1 is for the gender picker
            return genderOptions.count
        } else if pickerView.tag == 2 { // Assuming tag 2 is for the age picker
            return ageOptions.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return genderOptions[row]
        } else if pickerView.tag == 2 {
            return "\(ageOptions[row])"
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        saveBarButton.isEnabled = true
    }
}

//MARK: - UITextFieldDelegate -

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        saveBarButton.isEnabled = true
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Set the picked image to your profileImageView
            profileImageView.image = selectedImage
            saveBarButton.isEnabled = true
            if let user = Auth.auth().currentUser {
                userInfoVM.uploadProfileImageToStorage(uid: user.uid, image: profileImageView.image!) { profileImageURL in
                    if let profileImageURL = profileImageURL {
                        self.profileImageUrl = profileImageURL
                        print(profileImageURL)
                        print("Success uploading profile image to Firebase Storage")
                    } else {
                        print("Error uploading profile image to Firebase Storage.")
                    }
                }
            }

        }

        // Dismiss the UIImagePickerController
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
