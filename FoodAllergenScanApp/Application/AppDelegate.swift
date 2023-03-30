//
//  AppDelegate.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 3/22/23.
//

import GoogleSignIn
import FirebaseCore
import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "FoodAllergenScanApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveProduct(barcode: String, imageUrl: String?, productName: String?, brandName: String?, ingredients: String?, date: Date?) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
        
        do {
            let existingProducts = try context.fetch(fetchRequest)
            
            if existingProducts.isEmpty {
                let product = NSEntityDescription.insertNewObject(forEntityName: "Product", into: context) as! Product
                product.barcode = barcode
                product.imageUrl = imageUrl
                product.productName = productName
                product.brandName = brandName
                product.ingredients = ingredients
                product.date = date
                saveContext()
            } else {
                print("Product with barcode \(barcode) already exists.")
            }
        } catch let error {
            print("Error fetching existing products: \(error.localizedDescription)")
        }
    }
    
    
    func saveUserHealthInfo(healthyFood: [String], notRecommendedFood: [String], foodsToAvoid: [String]) {
        let context = persistentContainer.viewContext
        
        // Delete any existing UserHealthInfo object
        let fetchRequest: NSFetchRequest<HealthInfo> = HealthInfo.fetchRequest()
        do {
            let existingHealthInfo = try context.fetch(fetchRequest)
            for healthInfo in existingHealthInfo {
                context.delete(healthInfo)
            }
        } catch let error {
            print("Error fetching existing UserHealthInfo: \(error.localizedDescription)")
        }
        
        // Create a new UserHealthInfo object and set its attributes
        let healthInfo = NSEntityDescription.insertNewObject(forEntityName: "HealthInfo", into: context) as! HealthInfo
        healthInfo.healthyFood = healthyFood as NSObject
        healthInfo.notRecommendedFood = notRecommendedFood as NSObject
        healthInfo.foodsToAvoid = foodsToAvoid as NSObject
        
        // Save the changes to the context
        saveContext()
    }
    
    func fetchUserHealthInfo() -> HealthInfo? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<HealthInfo> = HealthInfo.fetchRequest()

        do {
            let healthInfoArray = try context.fetch(fetchRequest)
            return healthInfoArray.first
        } catch let error {
            print("Error fetching HealthInfo: \(error.localizedDescription)")
            return nil
        }
    }
}

