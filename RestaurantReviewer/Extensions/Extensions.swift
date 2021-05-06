//
//  Extensions.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/3/21.
//

import Foundation
import CoreData

extension Restaurant {
    
    /// This will use the totalStars and reviewCount derived properties to calculate the average review score.
    func averageReview() -> Double {
        guard totalStars != 0 || reviewCount != 0 else { return 0 }
        return totalStars / reviewCount
    }
    
    func cuisinesDisplay() -> String {
        (cuisines?.allObjects as? [Cuisine] ?? []).compactMap({ $0.name }).joined(separator: ", ")
    }
    
    func averageReviewDisplay() -> String {
        let value = averageReview()
        if value.isZero {
            return "N/A"
        } else {
            return String(format: "%.1f", value)
        }
    }
}
