//
//  CreateRestaurantViewModel.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import Foundation
import SwiftUI
import Combine
import CoreData


class CreateRestaurantViewModel: ObservableObject {
    
    @Published var savingEnabled = false
    @Published var error = false
    
    @Published var name: String = ""
    @Published var multiSelection = Set<Cuisine>()
    
    init() {
        
        /// If the user has not provided a name or cuisine type, keep save button disabled.
        Publishers.CombineLatest($name.map({ !$0.isEmpty }),
                                               $multiSelection.map({ !$0.isEmpty }))
                                .compactMap({ $0 && $1 })
                                .assign(to: &$savingEnabled)
    }
    
    func save(contextManager: NSManagedObjectContext) -> Bool {
        
        let restaurant = Restaurant(context: contextManager)
        restaurant.id = UUID()
        restaurant.name = name
        restaurant.cuisines = multiSelection as NSSet

        do {
            try contextManager.save()
            return true
        } catch {
            print("deal with errors here \(error)")
            self.error = true
            return false
        }
    }
}
