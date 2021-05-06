//
//  SceneDelegate.swift
//  RestaurantReviewer
//
//  Created by Robert Haworth on 5/1/21.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Toggling this to true will change the Root View Controller to the "SwiftUI" version. This version does not have edit/delete implemented as cell-swipe has yet to be implemented for Lists.
    let enableSwiftUI = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let rootViewController: UIViewController
        
        /// We are diverging between SwiftUI and UIKit for our entry screen, to demonstrate swipe actions as they are not properly implemented into SwiftUI yet.
        /// In a normal application request, I would prefer to work with  the designer to find an alternative way to enable the delete and edit actions as swipe gestures although being native actions, are less discoverable than other forms of design. This is intended to show both options are viable.
        if enableSwiftUI {
            let contentView = RestaurantsView(contextManager: ContextManager.instance)
                                .environment(\.managedObjectContext, ContextManager.instance.persistentContainer.viewContext)
            rootViewController = UIHostingController(rootView: contentView)
        } else {
            UINavigationBar.appearance().barTintColor = .white
            let contentView = RestaurantsViewController(viewModel: RestaurantsViewModel(contextManager: ContextManager.instance))
            rootViewController = UINavigationController(rootViewController: contentView)
        }
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = rootViewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        ContextManager.instance.saveContext()
    }


}

