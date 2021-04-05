//
// ScoreFive
// Varun Santhanam
//

import ProjectDescription

let project = Project(name: "ScoreKeeping",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                          Target(name: "ScoreKeeping",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.ScoreKeeping",
                                 infoPlist: "ScoreKeeping/Info.plist",
                                 sources: ["ScoreKeeping/**"],
                                 headers: Headers(public: "ScoreKeeping/ScoreKeeping.h",
                                                  private: [],
                                                  project: []),
                                 dependencies: [],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/ScoreKeeping.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/ScoreKeeping.xcconfig")),
                                                 defaultSettings: .recommended)),
                          Target(name: "ScoreKeepingTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.ScoreKeepingTests",
                                 infoPlist: "ScoreKeepingTests/Info.plist",
                                 sources: ["ScoreKeepingTests/**"],
                                 dependencies: [
                                     .target(name: "ScoreKeeping")
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/ScoreKeepingTests.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/ScoreKeepingTests.xcconfig")),
                                                 defaultSettings: .recommended))
                      ],
                      schemes: [
                          .init(name: "ScoreKeeping",
                                shared: true,
                                buildAction: BuildAction(targets: ["ScoreKeeping"]),
                                testAction: TestAction(targets: ["ScoreKeepingTests"]))
                      ])