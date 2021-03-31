//
// ScoreFive
// Varun Santhanam
//

import ProjectDescription

let project = Project(name: "FiveUI",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                          Target(name: "FiveUI",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.FiveUI",
                                 infoPlist: "FiveUI/Info.plist",
                                 sources: ["FiveUI/**"],
                                 headers: Headers(public: "FiveUI/FiveUI.h",
                                                  private: [],
                                                  project: []),
                                 dependencies: [
                                     .project(target: "SnapKit", path: "../../Vendor/SnapKit")
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/FiveUI.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/FiveUI.xcconfig")),
                                                 defaultSettings: .recommended)),
                          Target(name: "FiveUITests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.FiveUITests",
                                 infoPlist: "FiveUITests/Info.plist",
                                 sources: ["FiveUITests/**"],
                                 dependencies: [
                                     .target(name: "FiveUI")
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/FiveUITests.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/FiveUITests.xcconfig")),
                                                 defaultSettings: .recommended))
                      ],
                      schemes: [
                          .init(name: "FiveUI",
                                shared: true,
                                buildAction: BuildAction(targets: ["FiveUI"]),
                                testAction: TestAction(targets: ["FiveUITests"]))
                      ])
