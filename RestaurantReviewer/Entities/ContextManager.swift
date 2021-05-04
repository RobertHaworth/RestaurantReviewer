//
//  ContextManager.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import Foundation
import CoreData
import SwiftUI

class ContextManager {
    
    // MARK: - Singleton access.
    static let instance: ContextManager = ContextManager(inMemory: true)
    
    static var preview: ContextManager = {
        let controller = ContextManager(inMemory: true)
        
        let context = controller.persistentContainer.viewContext
        
        
        controller.populateData()
        
        controller.saveContext()
        
        return controller
    }()
    
    // MARK: - Core Data stack

    let persistentContainer: NSPersistentContainer
    
    
    
    init(inMemory: Bool) {
        
        persistentContainer = NSPersistentContainer(name: "RestaurantReviewer")
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            
            // Backfill error handling here.
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                self?.populateCuisines()
            }
        })
        
    }
    
    func previewRestaurant() -> Restaurant? {
        let context = persistentContainer.viewContext
        
        do {
            return try context.fetch(NSFetchRequest<Restaurant>(entityName: "Restaurant")).first(where: { ($0.reviews?.count ?? 0) > 0 })
        } catch {
            print("error retrieving restaurant for previews")
        }
        return nil
    }
    
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
    
    /// Pre Loading 3 restaurants
    func populateData() {
        let context = persistentContainer.viewContext
        
        do {
            let cuisines = try context.fetch(NSFetchRequest<Cuisine>(entityName: "Cuisine"))
            // No Reviews
            let restaurantOne = Restaurant(context: context)
            
            restaurantOne.id = UUID()
            restaurantOne.name = "MOOYAH Burgers"
            
            if let cuisine = cuisines.first {
                restaurantOne.cuisines = [cuisine]
            }
            
            
            /// Nine Reviews
            let restaurantTwo = Restaurant(context: context)
            
            restaurantTwo.id = UUID()
            restaurantTwo.name = "North and South"
            
            restaurantTwo.cuisines = Set(cuisines.filter({ $0.name == "Barbeque" || $0.name == "American" })) as NSSet
            
            
            let restaurantThree = Restaurant(context: context)
            
            restaurantThree.id = UUID()
            restaurantThree.name = "Tex Tubb's Taco Palace"
            
            restaurantThree.cuisines = Set(cuisines.filter({ $0.name == "Mexican" })) as NSSet
            
            let reviewOne = Review(context: context)
            
            reviewOne.id = UUID()
            reviewOne.visitDate = Date()
            reviewOne.createdDate = Date()
            reviewOne.notes = "Tex Tubb's may be the single greatest taco shop ever."
            reviewOne.starCount = 5
            
            restaurantThree.reviews = [reviewOne] as NSSet
        } catch {
            print("woopsies")
            fatalError("Systemic issue with saving of cuisines in prior step.")
        }
        
        saveContext()
    }
    
    /// MARK: - Default Cuisines implementation.
    fileprivate var defaultCuisineNames: [String] {
        return ["American", "Japanese", "Indian", "English", "Barbecue", "Mexican", "Italian", "Chinese", "Greek"]
    }
    
    func populateCuisines() {
        
        let context = persistentContainer.viewContext
        
        var cuisines: [Cuisine] = []
        defaultCuisineNames.forEach { name in
            let defaultObject = Cuisine(context: context)
            defaultObject.id = UUID()
            defaultObject.name = name
            
            cuisines.append(defaultObject)
        }
    
        saveContext()
    }
}
