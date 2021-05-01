//
//  ContentView.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
        
    @State private var showingSheet = false
    
    
    /// TODO: Deal with the case sensitive compare for sorting.
    @FetchRequest(entity: Restaurant.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Restaurant.name,
                                                     ascending: true)]
    ) var restaurants: FetchedResults<Restaurant>
    
    var body: some View {
        NavigationView {
            List(restaurants, rowContent: { content in
                Text(content.name ?? "")
            })
                .navigationBarTitle("Restaurant Reviewer")
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
                    CreateRestaurant(viewModel: CreateRestaurantViewModel()).environment(\.managedObjectContext, managedObjectContext)
        })
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = ContextManager.preview.persistentContainer.viewContext
        ContentView().environment(\.managedObjectContext, context)
    }
}
