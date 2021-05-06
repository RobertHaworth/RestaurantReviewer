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
    static let instance: ContextManager = {
        /// Change inMemory to false if you want on-disk persistence.
        let controller = ContextManager(inMemory: false)
        
        controller.initialRestaurant()
        
        controller.saveContext()
        return controller
    }()
    
    /// Provides instance to pre-generate data to be used for SwiftUI Preview's, and likely Unit Testing.
    static var preview: ContextManager = {
        let controller = ContextManager(inMemory: true)
        
        let context = controller.persistentContainer.viewContext
        
        
        controller.previewData()
        
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
    
    /// Using this exclusively to easily load a Restaurant for SwiftUI previews.
    func previewRestaurant() -> Restaurant? {
        let context = persistentContainer.viewContext
        
        do {
            return try context.fetch(Restaurant.fetchRequest()).first(where: { ($0.reviews?.count ?? 0) > 0 })
        } catch {
            print("error retrieving restaurant for previews")
        }
        return nil
    }
    
    func delete(object: NSManagedObject) -> Result<Bool, Error> {
        let context = persistentContainer.viewContext
        context.delete(object)
        do {
            try context.save()
            return Result.success(true)
        } catch {
            return Result.failure(error)
        }
    }
    
    // MARK: - Core Data Saving support

    /// Returns true if save was successful and there were changes, false if there was no changes to save, and error if an error occurs during save.
    @discardableResult
    func saveContext() -> Result<Bool, Error> {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return Result.success(true)
            } catch {
                print("error found in save context \(error)")
                return Result.failure(error)
            }
        } else {
            return Result.success(false)
        }
    }
    
    func cuisines() -> [Cuisine] {
        let context = persistentContainer.viewContext
        do {
            let request = NSFetchRequest<Cuisine>(entityName: "Cuisine")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Cuisine.name, ascending: true)]
            let cuisines = try context.fetch(request)
            
            return cuisines
        } catch {
            return []
        }
    }
    
    
    /// Adds an initial restaurant if there is not one. This is for demo purposes.
    fileprivate func initialRestaurant() {
        guard !cuisines().isEmpty else { return }
        
        do {
            if try !persistentContainer.viewContext.fetch(Restaurant.fetchRequest()).isEmpty {
                return
            }
        } catch {
            return
        }
        
        let context = persistentContainer.viewContext
        
        let cuisineArray = cuisines()
        
        let demoRestaurant = Restaurant(context: context)
        
        demoRestaurant.id = UUID()
        demoRestaurant.name = "Tex Tubb's Taco Palace"
        
        if let cuisineType = cuisineArray.first(where: { $0.name == "Mexican" }) {
            demoRestaurant.cuisines = [cuisineType]
        }
        
        let myReview = Review(context: context)
        myReview.id = UUID()
        myReview.createdDate = Date()
        myReview.visitDate = Date()
        myReview.notes = "Tex Tubb's Taco Palace is a fantastic taco shop. It has great food, intimate seating, and a fantastic salsa bar."
        myReview.starCount = Double(5)
        
        demoRestaurant.reviews = [myReview]
        
    }
    
    /// Pre Loading 3 restaurants
    fileprivate func previewData() {
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
            reviewOne.createdDate = Date()
            reviewOne.visitDate = Date()
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
        
        guard cuisines().isEmpty else { return }
        
        let context = persistentContainer.viewContext
        
        
        var cuisines: [Cuisine] = []
        defaultCuisineNames.forEach { name in
            let defaultObject = Cuisine(context: context)
            defaultObject.id = UUID()
            defaultObject.name = name
            defaultObject.restaurants = NSSet()
            cuisines.append(defaultObject)
        }
        saveContext()
    }
}
