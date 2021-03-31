//
// ScoreFive
// Varun Santhanam
//

import Analytics
import CoreData
import Logging
import NeedleFoundation
import os.log
import ShortRibs
import UIKit

@main
class ScoreFiveAppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        startAnalytics()
        registerProviderFactories()
        AnalyticsManager.shared.send(event: AnalyticsEvent.app_launch, segmentation: nil)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        .init(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - API

    static var shared: ScoreFiveAppDelegate {
        guard let delegate = UIApplication.shared.delegate as? ScoreFiveAppDelegate else {
            fatalError("Invalid App Delegate Class")
        }
        return delegate
    }

    lazy var persistentContainer: PersistentContaining = {
        guard let url = Bundle.main.url(forResource: "ScoreFive", withExtension: "momd") else {
            fatalError("Missing persistent storage data model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to create model from url")
        }
        let container = NSPersistentContainer(name: "ScoreFive", managedObjectModel: managedObjectModel)
        let persistentContainer = PersistentContainer(container)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError()
            }
        }
        return persistentContainer
    }()

    // MARK: - Private

    private func startAnalytics() {
        do {
            guard let file = Bundle.main.url(forResource: "analytics_config", withExtension: "json") else {
                fatalError("""
                Fatal: Invalid Analytics Configuration Resource
                Run `./sftool bootstrap` and regenerate the project
                """)
            }
            let data = try Data(contentsOf: file)
            let config = try JSONDecoder().decode(AnalyticsConfig.self, from: data)
            if let urlString = config.host {
                if let url = URL(string: urlString) {
                    os_log("Starting analytics on host: %{public}@", log: .standard, type: .info, url.description)
                } else {
                    fatalError("Invalid Host Url \(urlString)!")
                }
            }
            AnalyticsManager.shared.eventPrefix = "sf_"
            AnalyticsManager.shared.startAnalytics(with: config)
        } catch {
            fatalError("Broken Analytics Configuration: \(error.localizedDescription)")
        }
    }
}
