//
//  ArrayExtension.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/3/21.
//

import Foundation

extension Array where Element == Review {
    
    /// Calculates the average score across each element in the array, and returns the value in Double format.
    func averageReviewScore () -> Double {
        
        /// Returning 0 if there is no score, we will not be providing the ability for lower than 1 star review's.
        guard !isEmpty else { return 0 }
        
        let totalScore = map({ $0.starCount }).reduce(0, { $0 + Int($1) })
        
        return Double(totalScore) / Double(count)
    }
    
    /// Formats the averageReviewScore Double value into a string representation for display to the user.
    func reviewAverage() -> String {
        let reviewNumber = averageReviewScore()
        if reviewNumber == 0 {
            return "N/A"
        } else {
            return String(format: "%.1f", reviewNumber)
        }
    }
}
