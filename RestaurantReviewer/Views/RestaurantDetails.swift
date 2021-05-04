//
//  RestaurantDetails.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import SwiftUI
import CoreData

struct RestaurantDetails: View {
    
    @Environment(\.managedObjectContext) var context
    @State var createReview = false
    
    @ObservedObject var viewModel: RestaurantDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                RatingView(reviews: viewModel.reviews)
                Text(viewModel.restaurant.name ?? "").font(.title)
            }
            ReviewList(reviews: viewModel.reviews)
        }.padding([.horizontal, .bottom], 10)
        .navigationBarTitle("Reviews")
        .toolbar(content: {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { createReview = true },
                       label: {
                    Image(systemName: "plus")
                })
            }
        })
        .sheet(isPresented: $createReview,
               content: {
                CreateReview(viewModel: CreateReviewViewModel(for: viewModel.restaurant)).environment(\.managedObjectContext, context)
        })
    }
}

struct ReviewList: View {
    
    var reviews: [Review]
    
    var body: some View {
        List(reviews) { review in
            VStack(alignment: .leading) {
                Text(review.notes ?? "")
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 16.0).stroke(Color.gray, lineWidth: 2.0))
                    .background(Color.blue.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                HStack {
                    ForEach(1..<6) { index in
                        Int(review.starCount) >= index ? Image(systemName: "star.fill").foregroundColor(.yellow) : Image(systemName: "star").foregroundColor(.yellow)
                    }
                    Spacer()
                    Text("visit date:").font(.callout)
                    Text(review.visitDate!, style: .date).font(.callout)
                }.padding(.horizontal, 8)
            }
        }
    }
}

struct RatingView: View {
    
    var reviews: [Review]
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(systemName: "star.fill")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(.yellow)
                .frame(width: 100, height: 100, alignment: .center)
            Text(reviews.reviewAverage()).font(.headline)
        }
    }
}

struct RestaurantDetails_Previews: PreviewProvider {
    static var previews: some View {
        let previewer = ContextManager.preview

        let restaurant = previewer.previewRestaurant()
        
        return RestaurantDetails(viewModel: RestaurantDetailViewModel(context: previewer.persistentContainer.viewContext, restaurant: restaurant!)).environment(\.managedObjectContext, previewer.persistentContainer.viewContext)
    }
}
