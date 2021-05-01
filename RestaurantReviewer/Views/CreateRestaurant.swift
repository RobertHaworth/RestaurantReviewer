//
//  CreateRestaurant.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import SwiftUI

struct CreateRestaurant: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var viewModel: CreateRestaurantViewModel
    
    @FetchRequest(entity: Cuisine.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Cuisine.name,
                                                     ascending: true)]
    ) var cuisines: FetchedResults<Cuisine>
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Enter your Restaurant name:")
                    TextField("North and South", text: $viewModel.name)
                        .padding(4)
                        .border(Color.black,
                                width: 1)
                        .disableAutocorrection(true)
                }.padding(.horizontal, 16)
                List(cuisines,
                     rowContent:{ content in
                        RowContent(name: content.name ?? "",
                                   selected: viewModel.multiSelection.contains(content))
                            .onTapGesture {
                                if viewModel.multiSelection.contains(content) {
                                    viewModel.multiSelection.remove(content)
                            } else {
                                viewModel.multiSelection.insert(content)
                            }
                        }
                     })
            }
            .padding(0)
            .toolbar(content: {
                    ToolbarItem(placement: .principal) {
                        Text("New Restaurant")
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { presentationMode.wrappedValue.dismiss() },
                               label: { Text("Cancel") })
                    }
                    ToolbarItem(placement: .primaryAction,
                                content: {
                                    Button(action: {
                                        if viewModel.save(contextManager: context) {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    },
                                    label: { Text("Save") })
                                    .disabled(!viewModel.savingEnabled)
                    })
                })
        }.alert(isPresented: $viewModel.error, content: {
            Alert(title: Text("Save Failure"),
                  message: Text("Unable to save restaurant at this time, please try again later"),
                  dismissButton: .default(Text("Got it!")))
            
        })
    }
}

struct RowContent: View {
    
    var name: String
    var selected: Bool
    
    var body: some View {
        HStack {
            selected ? Image(systemName: "checkmark.circle.fill").foregroundColor(.blue) : Image(systemName: "circle").foregroundColor(.black)
            Text(name)
        }
    }
}

struct CreateRestaurant_Previews: PreviewProvider {
    static var previews: some View {
        let context = ContextManager.preview.persistentContainer.viewContext
        CreateRestaurant(viewModel: CreateRestaurantViewModel()).environment(\.managedObjectContext, context)
    }
}
