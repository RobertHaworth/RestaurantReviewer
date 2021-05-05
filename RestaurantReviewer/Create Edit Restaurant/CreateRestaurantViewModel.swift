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
    
    private let editObject: Restaurant?
    
    private let contextManager: ContextManager
    
    init(contextManager: ContextManager, restaurant: Restaurant? = nil) {
        self.contextManager = contextManager
        
        if let uwRest = restaurant {
            editObject = restaurant
            
            name = uwRest.name ?? ""
            multiSelection = uwRest.cuisines as? Set<Cuisine> ?? Set<Cuisine>()
        } else {
            editObject = nil
        }
        
        /// If the user has not provided a name or cuisine type, keep save button disabled.
        Publishers.CombineLatest($name.map({ !$0.isEmpty }),
                                               $multiSelection.map({ !$0.isEmpty }))
                                .compactMap({ $0 && $1 })
                                .assign(to: &$savingEnabled)
        
    }
    
    func viewTitle() -> String {
        return editObject == nil ? "New Restaurant" : "Edit Restaurant"
    }
    
    func save() -> Bool {
        
        let restaurant = editObject ?? Restaurant(context: contextManager.persistentContainer.viewContext)
        restaurant.id = editObject?.id ?? UUID()
        restaurant.name = name
        restaurant.cuisines = multiSelection as NSSet

        switch contextManager.saveContext() {
        case let .success(result): return result
        case .failure(_):
            error = true
            return false
        }
    }
}
