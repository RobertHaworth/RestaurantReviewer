//
//  RestaurantReviewerTests.swift
//  RestaurantReviewerTests
//
//  Created by Robert Haworth on 5/1/21.
//

import XCTest
import CoreData
@testable import RestaurantReviewer

class RestaurantReviewerTests: XCTestCase {
    
    var manager: ContextManager!

    override func setUpWithError() throws {
        manager = ContextManager.preview
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        manager = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateRestaurant() {
        let viewModel = CreateRestaurantViewModel(contextManager: manager)
        
        let cuisine = manager.cuisines().first(where: { $0.name == "American" })
        
        viewModel.name = "Example Restaurant"
        viewModel.multiSelection = [cuisine!]
        
        _ = viewModel.save()
        
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Example Restaurant")
        do {
            let response = try manager.persistentContainer.viewContext.fetch(request)
            XCTAssert(response.count == 1)
            guard let firstRestaurant = response.first else { return }
            XCTAssert(firstRestaurant.cuisines?.count == 1)
        } catch {
            XCTFail("unable to fetch restaurants from context.")
        }
    }
    
    func testDeleteRestaurant() {
        let viewModel = RestaurantsViewModel(contextManager: manager)
        
        let count = viewModel.restaurants.count
        
        let restaurantToDelete = viewModel.restaurants.first!
        
        XCTAssert(viewModel.delete(restaurant: restaurantToDelete)) /// expect function to return true
        XCTAssert((count - 1) == viewModel.restaurants.count) /// expect restaurants count to go down by 1.
        XCTAssertFalse(viewModel.restaurants.contains(restaurantToDelete)) /// expect restaurant to no longer be in array.
    }
    
    func testEditRestaurantName() {
        let restaurant = manager.previewRestaurant()
        let newRestaurantName = "New Name"
        let oldName = restaurant?.name ?? ""
        
        let viewModel = CreateRestaurantViewModel(contextManager: manager, restaurant: restaurant)
        
        viewModel.name = newRestaurantName
        _ = viewModel.save()
        
        XCTAssertFalse(oldName == newRestaurantName)
        XCTAssert(restaurant?.name == newRestaurantName)
    }
}
