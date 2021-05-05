//
//  RestaurantsViewController.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/5/21.
//

import UIKit
import Combine
import SwiftUI

class RestaurantsViewController: UIViewController {
    
    private enum Section {
        case main
    }
    
    private let viewModel: RestaurantsViewModel
    
    private var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Restaurant>!
    
    private var cancellable: AnyCancellable?
    
    
    init(viewModel: RestaurantsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setupCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)

        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            
            // If we can't access the restaurant, we can't take any actions.
            guard let item = self?.dataSource.itemIdentifier(for: indexPath) else {
                return UISwipeActionsConfiguration(actions: [])
            }
            
            let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completion in
                completion(self?.viewModel.delete(restaurant: item) ?? false)
            }
            
            let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
                completion(true)
                self?.edit(restaurant: item)
            }
            
            return UISwipeActionsConfiguration(actions: [delete, edit])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.delegate = self
        collectionView.backgroundColor = .white
    }
    
    private func setupDatasource() {
        let cellProvider = UICollectionView.CellRegistration<RestaurantCollectionViewCell, Restaurant> { cell, indexPath, item in
            cell.setup(restaurant: item)
            cell.accessories = [.disclosureIndicator()]
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Restaurant>(collectionView: collectionView,
                                                                             cellProvider: { cv, path, item in
            return cv.dequeueConfiguredReusableCell(using: cellProvider, for: path, item: item)
        })
        
    }
    
    private func setupCombine() {
        cancellable = viewModel
                            .$restaurants
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] updatedRestaurants in
                                guard let self = self else { return }
                                var snapshot = self.dataSource.snapshot()
                                snapshot.deleteAllItems()
                                snapshot.appendSections([.main])
                                snapshot.appendItems(updatedRestaurants)
                                self.dataSource.apply(snapshot)
                                self.collectionView.reloadData() // This shouldn't be necessary.
                            }
    }
    
    func setupLayout() {
        
        setupCollectionView()
        setupDatasource()
        setupCombine()
        
        view.addSubview(collectionView)
        view.backgroundColor = .white
        title = "Foodie!"
            
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(createRestaurant))
        
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    
    /// Launches the CreateRestaurant screen.
    @objc
    func createRestaurant() {
        
        let createScreen = CreateRestaurant(viewModel: CreateRestaurantViewModel(contextManager: viewModel.contextManager),
                                            dismissAction: { [weak self] in self?.dismiss(animated: true,
                                                                                                                                  
                                                                                          completion: nil)})
            .environment(\.managedObjectContext, viewModel.contextManager.persistentContainer.viewContext)
        
        let host = UIHostingController(rootView: createScreen)
        present(host, animated: true, completion: nil)
    }
    
    /// Launches the CreateRestaurant screen in "edit" mode
    func edit(restaurant: Restaurant) {
        let createScreen = CreateRestaurant(viewModel: CreateRestaurantViewModel(contextManager: viewModel.contextManager,
                                                                                 restaurant: restaurant),
                                            dismissAction: { [weak self] in self?.dismiss(animated: true,
                                                                                                                                  
                                                                                          completion: { [weak self] in self?.collectionView.reloadData()
                                                                                            
                                                                                          })})
                                            .environment(\.managedObjectContext, viewModel.contextManager.persistentContainer.viewContext)
        
        let host = UIHostingController(rootView: createScreen)
        present(host, animated: true, completion: nil)
    }
}

extension RestaurantsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let test = UIHostingController(rootView: ReviewsView(viewModel: ReviewsViewModel(contextManager: viewModel.contextManager,
                                                                                                        restaurant: item)))
        
        navigationController?.pushViewController(test, animated: true)
    }
}
