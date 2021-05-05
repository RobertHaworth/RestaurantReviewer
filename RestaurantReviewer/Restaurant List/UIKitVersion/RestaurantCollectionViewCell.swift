//
//  RestaurantCollectionViewCell.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/5/21.
//

import UIKit
import SwiftUI

class RestaurantCollectionViewCell: UICollectionViewListCell {
    
    private let starView = StarView()
    private let restaurantTitleLabel = UILabel()
    private let cuisineLabel = UILabel()
    
    private let reviewView = ReviewCountView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private func setupLayout() {
        
        contentView.addSubview(starView)
        
        contentView.addSubview(restaurantTitleLabel)
        contentView.addSubview(cuisineLabel)
        
        contentView.addSubview(reviewView)
        
        restaurantTitleLabel.font = UIFont.systemFont(ofSize: 18.0)
        cuisineLabel.font = UIFont.systemFont(ofSize: 14.0)
        
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        starView.translatesAutoresizingMaskIntoConstraints = false
        restaurantTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cuisineLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalTo: topAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     contentView.leadingAnchor.constraint(equalTo: leadingAnchor)])
        
        NSLayoutConstraint.activate([starView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     starView.widthAnchor.constraint(equalToConstant: 75.0),
                                     starView.heightAnchor.constraint(equalTo: starView.widthAnchor),
                                     starView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0)])
        
        NSLayoutConstraint.activate([restaurantTitleLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
                                        restaurantTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
                                     restaurantTitleLabel.leadingAnchor.constraint(equalTo: starView.trailingAnchor, constant: 8.0),
                                     restaurantTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: reviewView.leadingAnchor, constant: -16.0)])
        
        NSLayoutConstraint.activate([cuisineLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16.0),
                                     cuisineLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     cuisineLabel.leadingAnchor.constraint(equalTo: restaurantTitleLabel.leadingAnchor),
                                     cuisineLabel.trailingAnchor.constraint(lessThanOrEqualTo: reviewView.leadingAnchor, constant: -16.0)])
        
        
        /// Arbitrary constant offset is not the best here, due to accessories not seemingly being visible to the cell at point of setup.
        NSLayoutConstraint.activate([reviewView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     reviewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40.0),
                                     reviewView.widthAnchor.constraint(equalToConstant: 30.0),
                                     reviewView.heightAnchor.constraint(equalTo: reviewView.widthAnchor)])
        
        
    }
    
    func setup(restaurant: Restaurant) {
        starView.setup(rating: restaurant.averageReview())
        reviewView.setup(totalReviews: Int(restaurant.reviewCount))
        restaurantTitleLabel.text = restaurant.name
        cuisineLabel.text = restaurant.cuisinesDisplay()
    }
    
    private class ReviewCountView: UIView {
        
        let label = UILabel(frame: .zero)
        
        init() {
            super.init(frame: .zero)
            setupLayout()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupLayout()
        }
        
        private func setupLayout() {
            addSubview(label)
            
            backgroundColor = UIColor(Color.blue.opacity(0.4))
            layer.cornerRadius = 15.0
            
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([label.centerYAnchor.constraint(equalTo: centerYAnchor),
                                         label.centerXAnchor.constraint(equalTo: centerXAnchor)])
        }
        
        func setup(totalReviews: Int) {
            label.text = "\(totalReviews)"
        }
    }
    
    private class StarView: UIView {
        private let starView = UIImageView(image: UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(Color.yellow)))
        private let averageRatingLabel = UILabel()
        
        init() {
            super.init(frame: .zero)
            setupLayout()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupLayout()
        }
        
        private func setupLayout() {
            addSubview(starView)
            addSubview(averageRatingLabel)
            
            averageRatingLabel.font = UIFont.systemFont(ofSize: 16.0)
            
            starView.translatesAutoresizingMaskIntoConstraints = false
            averageRatingLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            NSLayoutConstraint.activate([starView.topAnchor.constraint(equalTo: topAnchor),
                                         starView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                         starView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                         starView.bottomAnchor.constraint(equalTo: bottomAnchor)])
            
            NSLayoutConstraint.activate([averageRatingLabel.centerYAnchor.constraint(equalTo: starView.centerYAnchor),
                                         averageRatingLabel.centerXAnchor.constraint(equalTo: starView.centerXAnchor)])
        }
        
        func setup(rating: Double) {
            if rating.isZero {
                averageRatingLabel.text = "N/A"
            } else {
                averageRatingLabel.text = String(format: "%.1f", rating)
            }
            
        }
    }
}
