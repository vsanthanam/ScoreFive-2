//
// ScoreFive
// Varun Santhanam
//

import ProjectDescription

let project = Project(name: "AppFoundation",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                          Target(name: "AppFoundation",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.AppFoundation",
                                 infoPlist: "AppFoundation/Info.plist",
                                 sources: ["AppFoundation/**"],
                                 headers: Headers(public: "AppFoundation/AppFoundation.h",
                                                  private: [],
                                                  project: []),
                                 dependencies: [],
                                 settings: .init(base: [:],
                                                 debug: .init(settings: [:], xcconfig: .relativeToManifest("Config/AppFoundation.xcconfig")),
                                                 release: .init(settings: [:], xcconfig: .relativeToManifest("Config/AppFoundation.xcconfig")),
                                                 defaultSettings: .recommended)),
                          Target(name: "AppFoundationTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.AppFoundationTests",
                                 infoPlist: "AppFoundationTests/Info.plist",
                                 sources: ["AppFoundationTests/**"],
                                 dependencies: [
                                     .target(name: "AppFoundation"),
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .init(settings: [:], xcconfig: .relativeToManifest("Config/AppFoundationTests.xcconfig")),
                                                 release: .init(settings: [:], xcconfig: .relativeToManifest("Config/AppFoundationTests.xcconfig")),
                                                 defaultSettings: .recommended)),
                      ],
                      schemes: [
                          .init(name: "AppFoundation",
                                shared: true,
                                buildAction: BuildAction(targets: ["AppFoundation"]),
                                testAction: TestAction(targets: ["AppFoundationTests"])),
                      ])
