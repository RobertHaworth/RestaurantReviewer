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
    
    // MARK: - Core Data stack

    let persistentContainer: NSPersistentContainer
    
    static var preview: ContextManager = {
        let controller = ContextManager(inMemory: true)
        
        let context = controller.persistentContainer.viewContext
        (0...5).forEach { enumeratedValue in
            let test = Restaurant(context: context)
            test.id = UUID()
            test.name = "Example Restaurant \(enumeratedValue)"
        }
        
        controller.previewData()
        
        controller.saveContext()
        return controller
    }()
    
    init(inMemory: Bool) {
        
        persistentContainer = NSPersistentContainer(name: "RestaurantReviewer")
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            // Backfill error handling here.
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
    }
    
    
    func containsData() -> Bool {
        do {
            let restaurantCount = try persistentContainer.viewContext.count(for: NSFetchRequest<Restaurant>(entityName: "Restaurant"))
            return restaurantCount != 0
        } catch {
            return false
        }
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
    
    fileprivate var defaultCuisineNames: [String] {
        return ["American", "Asian", "Indian", "English", "Barbecue", "Mexican", "Dutch", "Spanish"]
    }
    
    func previewData() {
        
        let context = persistentContainer.viewContext
        
        defaultCuisineNames.forEach { name in
            let defaultObject = Cuisine(context: context)
            defaultObject.id = UUID()
            defaultObject.name = name
        }
    
        saveContext()
    }
}
