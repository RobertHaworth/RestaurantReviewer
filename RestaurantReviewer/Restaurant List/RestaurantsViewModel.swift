//
//  RestaurantsViewModel.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/4/21.
//

import Foundation
import CoreData
import SwiftUI

enum SortType: Int, CaseIterable {
    case averageRating,
         name,
         totalReviews
    
    func description() -> String {
        switch self {
        case .averageRating: return "Average Rating"
        case .name: return "Name"
        case .totalReviews: return "Total Reviews"
        }
    }
    
    
}

class RestaurantsViewModel: NSObject, ObservableObject {
    
    private var resultsController: NSFetchedResultsController<Restaurant>?
    
    @Published var restaurants: [Restaurant] = []
    
    
    let contextManager: ContextManager
    
    var sortType: SortType = .name {
        didSet {
            fetch()
        }
    }
    
    init(contextManager: ContextManager) {
        self.contextManager = contextManager
        super.init()
    }
    
    func fetch() {
        
        var sortDescriptors: [NSSortDescriptor] = []
        
        switch sortType {
        case .name:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Restaurant.name, ascending: true))
        case .totalReviews:
            sortDescriptors.append(NSSortDescriptor(keyPath: \Restaurant.reviewCount, ascending: false))
        default: break
        }
        
        if let existingController = resultsController {
            existingController.fetchRequest.sortDescriptors = sortDescriptors
            
        } else {
            let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
            
            request.sortDescriptors = sortDescriptors
            
            resultsController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: contextManager.persistentContainer.viewContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
            
            resultsController?.delegate = self
        }
        
        
        do {
            try resultsController?.performFetch()
            if sortType == .averageRating {
                restaurants = (resultsController?.fetchedObjects ?? []).sorted(by: { $0.averageReview() > $1.averageReview() })
            } else {
                restaurants = (resultsController?.fetchedObjects ?? [])
            }
            
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
        
        if sortType == .averageRating {
            restaurants = items.sorted(by: { $0.averageReview() > $1.averageReview() })
        } else {
            restaurants = items
        }
    }
}
