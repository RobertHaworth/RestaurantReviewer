//
//  CreateReview.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/2/21.
//

import SwiftUI

struct CreateReview: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var viewModel: CreateReviewViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                DatePicker("Visit Date",
                           selection: $viewModel.visitDate,
                           in: PartialRangeThrough(Date()))
                StarView(ratingValue: $viewModel.reviewRating)
                Text("Enter your Review: ")
                TextEditor(text: $viewModel.reviewText)
                    .cornerRadius(8.0, antialiased: true)
                .border(Color.black, width: 1)
                .frame(maxWidth: .infinity, maxHeight: 250.0, alignment: .top)
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Create Review")
            .toolbar(content: {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        if viewModel.save() {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            /// Do the Error.
                        }
                    }, label: {
                        Text("Save")
                    })
                }
            })
        }
    }
}

struct StarView: View {
    
    @Binding var ratingValue: Int
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(1..<6) { index in
                Button(action: { ratingValue = index }, label: {
                    ratingValue >= index ? Image(systemName: "star.fill") : Image(systemName: "star")
                })
                .padding(2)
                .foregroundColor(.yellow)
            }
        }
    }
}

struct CreateReview_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = ContextManager.preview
        let restaurant = previewContext.previewRestaurant()!
        CreateReview(viewModel: CreateReviewViewModel(contextManager: ContextManager.preview, for: restaurant))
    }
}
