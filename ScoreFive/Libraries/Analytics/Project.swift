//
// ScoreFive
// Varun Santhanam
//

import ProjectDescription

let project = Project(name: "Analytics",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                          Target(name: "Analytics",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.Analytics",
                                 infoPlist: "Analytics/Info.plist",
                                 sources: ["Analytics/**"],
                                 headers: Headers(public: "Analytics/Analytics.h",
                                                  private: [],
                                                  project: []),
                                 dependencies: [
                                     .project(target: "Logging", path: "../Logging"),
                                     .project(target: "Countly", path: "../../Vendor/Countly"),
                                     .project(target: "AppFoundation", path: "../AppFoundation")
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/Analytics.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/Analytics.xcconfig")),
                                                 defaultSettings: .recommended)),
                          Target(name: "AnalyticsTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.AnalyticsTests",
                                 infoPlist: "AnalyticsTests/Info.plist",
                                 sources: ["AnalyticsTests/**"],
                                 dependencies: [
                                     .target(name: "Analytics")
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/AnalyticsTests.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/AnalyticsTests.xcconfig")),
                                                 defaultSettings: .recommended))
                      ],
                      schemes: [
                          .init(name: "Analytics",
                                shared: true,
                                buildAction: BuildAction(targets: ["Analytics"]),
                                testAction: TestAction(targets: ["AnalyticsTests"]))
                      ])
