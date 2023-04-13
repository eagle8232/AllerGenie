//
//  ScanViewController.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import AVFoundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import Vision
import Kingfisher


class ScanViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var detectBarcodeRequest: VNDetectBarcodesRequest!
    var networking = Networking()
    
    let db = Firestore.firestore()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var matchPopUpView: UIView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var brandNameLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var moreDetailsButton: UIButton!
    @IBOutlet weak var matchResultLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var customTabBar: UIView?
    
    var ingredients: String?
    var productImageUrlString: String?
    
    let userInfoVM = UserInfoViewModel()
    var allergenFood: AllergenFood?
    var healthInfoModel: HealthInfoModel?
    
    
    var healthyFood: [String] = []
    var notRecommendedFood: [String] = []
    var foodToAvoid: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        networking.delegate = self
        matchPopUpView.layer.cornerRadius = 25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func didTapMoreDetailsButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let productInfo = storyboard.instantiateViewController(withIdentifier: "ProductsInfoViewController") as? ProductsInfoViewController else {return}
        productInfo.customTabBar = customTabBar
        productInfo.productImageUrlString = productImageUrlString
        productInfo.allergenFood = allergenFood
        productInfo.healthInfoModel = healthInfoModel
        navigationController?.pushViewController(productInfo, animated: true)
    }
    
    
    @IBAction func didTapHideButton(_ sender: UIButton) {
        matchPopUpView.isHidden = true
        //As it desappears start the camera
        DispatchQueue(label: "background", qos: DispatchQoS.background).async {
            self.captureSession.startRunning()
        }
    }
    
    func showPopUpView() {
        view.addSubview(matchPopUpView)
        matchPopUpView.isHidden = false
        NSLayoutConstraint.activate([
            matchPopUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            matchPopUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            matchPopUpView.heightAnchor.constraint(equalToConstant: 200),
            ])
            
            let bottomConstraint = matchPopUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 200)
            bottomConstraint.isActive = true
            view.layoutIfNeeded()
            
            bottomConstraint.constant = -120
            
            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            })
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        detectBarcodeRequest = VNDetectBarcodesRequest(completionHandler: detectBarcodeHandler)
        
        DispatchQueue(label: "background", qos: DispatchQoS.background).async {
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
        do {
            try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
            print(error)
        }
    }
    
    
    func detectBarcodeHandler(request: VNRequest, error: Error?) {
        guard let barcodes = request.results as? [VNBarcodeObservation] else { return }
        for barcode in barcodes {
            guard let payload = barcode.payloadStringValue else { continue }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.found(code: payload)
            InternetConnectionViewModel.showNoConnectionView(view: self.view) { success in
                if success {
                    self.networking.fetchProductInfo(barcode: payload) { [weak self] (productName, brand, ingredients, imageUrl) in
                        self?.allergenFood = AllergenFood(productName: productName ?? "", brand: brand ?? "", ingredients: ingredients ?? "")
                        self?.checkIfMatches(ingredients: ingredients ?? "")
                        
                        let today = Date()
                        self?.matchPopUpView.isHidden = false
                        if let url = URL(string: imageUrl ?? "") {
                            self?.productImageUrlString = imageUrl
                            self?.productImageView.kf.setImage(with: url)
                        }
                        self?.productNameLabel.text = productName
                        self?.brandNameLabel.text = brand
                        self?.ingredients = ingredients
                        self?.showPopUpView()
                        
                        //And save it to core data
                        //For now use "3017620422003"
                        self?.appDelegate.saveProduct(barcode: payload, imageUrl: imageUrl, productName: productName, brandName: brand, ingredients: ingredients, date: today)
                        
                    }
                }
            }
            
            print("Barcode: \(payload)")
            
            // Stop the capture session if needed
            captureSession.stopRunning()
        }
    }
    
    func checkIfMatches(ingredients: String) {
        DispatchQueue.main.async { [weak self] in
            if let user = Auth.auth().currentUser {
                if let healthyFood = self?.appDelegate.fetchUserHealthInfo()?.healthyFood as? [String],
                   let notRecommendedFood = self?.appDelegate.fetchUserHealthInfo()?.notRecommendedFood as? [String],
                   let foodToAvoid = self?.appDelegate.fetchUserHealthInfo()?.foodsToAvoid as? [String] {
                
                    self?.healthyFood = healthyFood
                    self?.notRecommendedFood = notRecommendedFood
                    self?.foodToAvoid = foodToAvoid
                    
                } else {
                    self?.userInfoVM.fetchHealthInfoFromFirestore(userId: user.uid, completion: { healthyFoods, notRecommendedFoods, foodsToAvoid in
                        self?.healthyFood = healthyFoods ?? [""]
                        self?.notRecommendedFood = notRecommendedFoods ?? [""]
                        self?.foodToAvoid = foodsToAvoid ?? [""]
                    })
                }
            }
            
            let ingredientsArray = self?.processTextFieldInput(ingredients)
            
            let healthyFoodMatch = ingredientsArray?.filter {self!.healthyFood.contains($0)} ?? [""]
            let notRecommendedFoodMatch = ingredientsArray?.filter {self!.notRecommendedFood.contains($0)} ?? [""]
            let foodsToAvoidMatch = ingredientsArray?.filter {self!.foodToAvoid.contains($0)} ?? [""]
            if !healthyFoodMatch.isEmpty {
                let color = UIColor(named: "pressedTabBarColor")
                self?.matchResultLabel.text = Matched.excellent.rawValue
                self?.matchResultLabel.textColor = color
            } else if !notRecommendedFoodMatch.isEmpty {
                let color = UIColor.systemYellow
                self?.matchResultLabel.text = Matched.average.rawValue
                self?.matchResultLabel.textColor = color
            } else if !foodsToAvoidMatch.isEmpty {
                let color = UIColor.red
                self?.matchResultLabel.text = Matched.avoid.rawValue
                self?.matchResultLabel.textColor = color
            } else {
                let color = UIColor.gray
                self?.matchResultLabel.text = Matched.not_recognized.rawValue
                self?.matchResultLabel.textColor = color
            }
        }
    }
    
    func found(code: String) {
        print("Barcode: \(code)")
    }
    
    func processTextFieldInput(_ input: String) -> [String] {
        return input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}

extension ScanViewController: NetworkingDelegate {
    func didGetAllergenData(_ data: AllergenFood) {
        self.showPopUpView()
    }
}
