//
//  RestaurantDetails.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import SwiftUI
import CoreData

struct ReviewsView: View {
    
    @Environment(\.presentationMode) var presentation
    @State var createReview = false
    
    @ObservedObject var viewModel: ReviewsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                RatingView(reviews: viewModel.restaurant.reviews?.allObjects as? [Review] ?? [],
                           formattedAverage: viewModel.restaurant.averageReviewDisplay())
                VStack(alignment: .leading) {
                    Text(viewModel.restaurant.name ?? "").font(.title)
                    Text(viewModel.restaurant.cuisinesDisplay())
                }
            }.padding(10)
            Rectangle()
                .foregroundColor(.gray.opacity(0.4))
                .frame(maxWidth: .infinity, maxHeight: 1.0, alignment: .center)
            ReviewList(reviews: viewModel.restaurant.reviews?.allObjects as? [Review] ?? []).padding([.horizontal, .bottom], 10)
        }
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
                CreateReview(viewModel: CreateReviewViewModel(contextManager: viewModel.contextManager, for: viewModel.restaurant))
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
                }
            }
        }
    }
}

struct RatingView: View {
    
    var reviews: [Review]
    var formattedAverage: String
    
    var body: some View {
        ZStack(alignment: .center) {
            Image(systemName: "star.fill")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(.yellow)
                .frame(width: 75, height: 75, alignment: .center)
            Text(formattedAverage).font(.subheadline)
        }
    }
}

struct RestaurantDetails_Previews: PreviewProvider {
    static var previews: some View {
        let previewer = ContextManager.preview

        let restaurant = previewer.previewRestaurant()
        
        return ReviewsView(viewModel: ReviewsViewModel(contextManager: ContextManager.preview,
                                                       restaurant: restaurant!))
    }
}
