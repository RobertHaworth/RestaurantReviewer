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
    
//    func sortDescriptor() -> NSSortDescriptor? {
//        switch self {
////        case .averageRating:
////            return NSSortDescriptor(keyPath: \Restaurant., ascending: <#T##Bool#>)
//        case .name:
//            return NSSortDescriptor(keyPath: \Restaurant.name, ascending: true)
//        case .cuisine:
//            return NSSortDescriptor(keyPath: \Restaurant.cuisines, ascending: true)
//        default: return nil
//        }
//    }
}

class RestaurantsViewModel: NSObject, ObservableObject {
    
    private var resultsController: NSFetchedResultsController<Restaurant>?
    
    @Published var restaurants: [Restaurant] = []
    
//    @State var sortState: SortType = .averageRating
    
//    let context: NSManagedObjectContext
    let contextManager: ContextManager
    
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init()
//        fetch()
//    }
    
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
