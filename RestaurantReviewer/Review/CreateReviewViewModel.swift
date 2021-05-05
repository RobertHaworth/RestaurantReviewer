//
//  CreateReviewViewModel.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/3/21.
//

import SwiftUI
import CoreData
import Combine

class CreateReviewViewModel: ObservableObject {
    @Published var visitDate: Date = Date()
    @Published var reviewRating: Int = 1
    @Published var reviewText: String = ""
    
    private let restaurant: Restaurant
    private let contextManager: ContextManager
    
    @Published var error = false
    
    init(contextManager: ContextManager, for restaurant: Restaurant) {
        self.contextManager = contextManager
        self.restaurant = restaurant
    }
    
    func save() -> Bool {
        let newReview = Review(context: contextManager.persistentContainer.viewContext)
        newReview.id = UUID()
        newReview.visitDate = visitDate
        newReview.createdDate = Date()
        newReview.notes = reviewText
        newReview.starCount = Double(reviewRating)
        newReview.restaurant = restaurant
        
        switch contextManager.saveContext() {
        case let .success(result): return result
        case .failure(_):
            self.error = true
            return false
        }
        
    }
}
