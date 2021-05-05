//
//  RestaurantsViewModel.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/4/21.
//

import Foundation
import CoreData
import SwiftUI

enum SortType {
    case averageRating, name, cuisine
    
}

class RestaurantsViewModel: NSObject, ObservableObject {
    
    private var resultsController: NSFetchedResultsController<Restaurant>?
    
    @Published var restaurants: [Restaurant] = []
    

    let contextManager: ContextManager
    
    
    init(contextManager: ContextManager) {
        self.contextManager = contextManager
        super.init()
        fetch()
    }
    
    func fetch() {
        
        
        if let existingController = resultsController {
            
            
        } else {
            let request = NSFetchRequest<Restaurant>(entityName: "Restaurant")
            
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Restaurant.name, ascending: true)]
            
            resultsController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: contextManager.persistentContainer.viewContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
            
            resultsController?.delegate = self
        }
        
        
        do {
            try resultsController?.performFetch()
            restaurants = resultsController?.fetchedObjects ?? []
        } catch {
            print("big problem")
        }
    }
    
    func delete(restaurant: Restaurant) -> Bool {
        switch contextManager.delete(object: restaurant) {
        case let .success(success): return success
        case .failure(_): // Do something with error
            return false
        }
    }
}

extension RestaurantsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [Restaurant] else { return }
        restaurants = items
    }
}
