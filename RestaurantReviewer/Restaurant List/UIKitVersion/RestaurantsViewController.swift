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
    
    private let segmentControl = UISegmentedControl()
    
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
    
    private func setupSegmentController() {
        
        segmentControl.selectedSegmentTintColor = UIColor(Color.blue.opacity(0.4))
        
        SortType.allCases
            .enumerated()
            .forEach { (index, type) in
                let action = UIAction(title: type.description(),
                                      handler: { [weak self] _ in self?.viewModel.sortType = type })
                
                segmentControl.insertSegment(action: action,
                                                at: index,
                                                animated: false)
                
                /// Setting the default sort type visible
                if viewModel.sortType == type {
                    segmentControl.selectedSegmentIndex = index
                }
        }
    }
    
    private func setupCombine() {
        cancellable = viewModel
                            .$restaurants
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] updatedRestaurants in
                                guard let self = self else { return }

                                var newSnapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
                                newSnapshot.appendSections([.main])
                                newSnapshot.appendItems(updatedRestaurants)

                                self.dataSource.apply(newSnapshot)
                                self.collectionView.reloadData()
                            }
    }
    
    func setupLayout() {
        
        setupCollectionView()
        setupSegmentController()
        setupDatasource()
        setupCombine()
        
        view.addSubview(segmentControl)
        view.addSubview(collectionView)
        view.backgroundColor = .white
        title = "Foodie!"
            
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(createRestaurant))
        
        
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0)])
        
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8.0),
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetch()
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
