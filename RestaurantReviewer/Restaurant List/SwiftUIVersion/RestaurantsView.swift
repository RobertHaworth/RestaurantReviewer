//
//  ContentView.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import SwiftUI

struct RestaurantsView: View {
    
    let contextManager: ContextManager
    
    @State private var showingSheet = false
    
    
    /// TODO: Deal with the case sensitive compare for sorting.
    @FetchRequest(entity: Restaurant.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Restaurant.name,
                                                     ascending: true)]
    ) var restaurants: FetchedResults<Restaurant>
    
    var body: some View {
        NavigationView {
            List(restaurants,
                 rowContent: { content in
                    NavigationLink(destination: ReviewsView(viewModel: ReviewsViewModel(contextManager: contextManager,
                                                                                        restaurant: content))) {
                        RestaurantView(content: content).environment(\.managedObjectContext, contextManager.persistentContainer.viewContext)
                    }
                 })
                .navigationBarTitle("Foodie!")
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showingSheet = true
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                })
        }.sheet(isPresented: $showingSheet,
                content: {
                    CreateRestaurant(viewModel: CreateRestaurantViewModel(contextManager: contextManager)).environment(\.managedObjectContext, contextManager.persistentContainer.viewContext)
                })
        
        
    }
}

private struct RestaurantView: View {
    var content: Restaurant
    
    var body: some View {
        HStack(alignment: .center) {
            RatingView(reviews: content.reviews?.allObjects as? [Review] ?? [],
                       formattedAverage: content.averageReviewDisplay())
            VStack(alignment: .leading) {
                Text(content.name ?? "").font(.headline)
                Text(content.cuisinesDisplay()).font(.subheadline)
            }
            Spacer()
            ZStack {
                Circle()
                    .foregroundColor(Color.blue.opacity(0.4))
                    .overlay(Text("\(content.reviews?.count ?? 0)"))
                    .frame(width: 40, height: 40, alignment: .center)
                    .cornerRadius(20)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantsView(contextManager: ContextManager.preview).environment(\.managedObjectContext, ContextManager.preview.persistentContainer.viewContext)
    }
}
