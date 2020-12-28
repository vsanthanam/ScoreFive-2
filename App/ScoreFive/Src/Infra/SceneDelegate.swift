//
//  SceneDelegate.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/25/20.
//

import UIKit
import ShortRibs

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - UIWindowSceneDelegate
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = .init(windowScene: scene)
        launchScene()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        root!.deactivate()
        root = nil
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
        try? (UIApplication.shared.delegate as! AppDelegate).persistentContainer.save()
    }

    // MARK: - Private
    
    private var root: PresentableInteractable?
    
    private func launchScene() {
        let builder = RootBuilder()
        root = builder.build(onWindow: window!,
                             persistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        window!.makeKeyAndVisible()
        root!.activate()
    }
}
