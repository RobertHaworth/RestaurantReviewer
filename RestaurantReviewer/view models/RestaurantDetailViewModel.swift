//
//  RestaurantDetailViewModel.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/3/21.
//

import SwiftUI
import Foundation
import CoreData

class RestaurantDetailViewModel: NSObject, ObservableObject {
    
    @Published var reviews: [Review] = []
    
    private let resultsController: NSFetchedResultsController<Review>
    
    let restaurant: Restaurant
    
    init(context: NSManagedObjectContext, restaurant: Restaurant) {
        self.restaurant = restaurant
        
        let request = NSFetchRequest<Review>(entityName: "Review")
        request.predicate = NSPredicate(format: "restaurant == %@", restaurant)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Review.createdDate, ascending: true)]
        
        resultsController = NSFetchedResultsController(fetchRequest: request,
                                                       managedObjectContext: context,
                                                       sectionNameKeyPath: nil,
                                                       cacheName: nil)
        
        super.init()
        
        resultsController.delegate = self
        
        do {
            try resultsController.performFetch()
            reviews = resultsController.fetchedObjects ?? []
        } catch {
            print("big problem")
        }
    }
}

extension RestaurantDetailViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let items = controller.fetchedObjects as? [Review] else { return }
        reviews = items
    }
}
