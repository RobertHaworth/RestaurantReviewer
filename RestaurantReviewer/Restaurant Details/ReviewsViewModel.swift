//
//  RestaurantDetailViewModel.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/3/21.
//

import SwiftUI
import Foundation
import CoreData

class ReviewsViewModel: NSObject, ObservableObject {
    
    let restaurant: Restaurant
    
    let contextManager: ContextManager
    
    init(contextManager: ContextManager, restaurant: Restaurant) {
        self.restaurant = restaurant
        self.contextManager = contextManager
        
    }
    
    // TODO: Add ability to edit reviews
    // TODO: Add ability to remove reviews
}
