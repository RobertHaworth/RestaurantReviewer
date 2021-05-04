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
    
    @Published var error = false
    
    init(for restaurant: Restaurant) {
        self.restaurant = restaurant
    }
    
    func save(with context: NSManagedObjectContext) -> Bool {
        let newReview = Review(context: context)
        newReview.id = UUID()
        newReview.visitDate = visitDate
        newReview.createdDate = Date()
        newReview.notes = reviewText
        newReview.starCount = Int16(reviewRating)
        newReview.restaurant = restaurant
        
        do {
            try context.save()
            return true
        } catch {
            print("deal with errors here \(error)")
            self.error = true
            return false
        }
    }
}
