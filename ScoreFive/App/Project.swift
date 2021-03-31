//
// ScoreFive
// Varun Santhanam
//

import ProjectDescription

let project = Project(name: "ScoreFive",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                          Target(name: "ScoreFive",
                                 platform: .iOS,
                                 product: .app,
                                 bundleId: "com.varunsanthanam.ScoreFive",
                                 infoPlist: "ScoreFive/Info.plist",
                                 sources: [
                                     "ScoreFive/Src/**"
                                 ],
                                 resources: [
                                     "ScoreFive/Resources/**"
                                 ],
                                 actions: [
                                     .pre(script: "../../sftool gen deps -r ../../", name: "Generate DI Graph")
                                 ],
                                 dependencies: [
                                     .project(target: "Analytics", path: "../Libraries/Analytics"),
                                     .project(target: "AppFoundation", path: "../Libraries/AppFoundation"),
                                     .project(target: "FiveUI", path: "../Libraries/FiveUI"),
                                     .project(target: "Logging", path: "../Libraries/Logging"),
                                     .project(target: "ScoreKeeping", path: "../Libraries/ScoreKeeping"),
                                     .project(target: "ShortRibs", path: "../Libraries/ShortRibs"),
                                     .project(target: "SnapKit", path: "../Vendor/SnapKit"),
                                     .project(target: "NeedleFoundation", path: "../Vendor/NeedleFoundation"),
                                     .project(target: "Countly", path: "../Vendor/Countly"),
                                     .project(target: "CombineSchedulers", path: "../Vendor/CombineSchedulers"),
                                     .sdk(name: "UIKit.framework", status: .required),
                                     .sdk(name: "Combine.framework", status: .required),
                                     .sdk(name: "CoreData.framework", status: .required)
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/ScoreFive.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/ScoreFive.xcconfig")),
                                                 defaultSettings: .recommended),
                                 coreDataModels: [
                                     .init("ScoreFive/ScoreFive.xcdatamodeld", currentVersion: "ScoreFive")
                                 ]),
                          Target(name: "ScoreFiveTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.ScoreFiveTests",
                                 infoPlist: "ScoreFiveTests/Info.plist",
                                 sources: [
                                     "ScoreFiveTests/**"
                                 ],
                                 actions: [
                                     .pre(script: "../../sftool gen mocks -r ../../", name: "Generate Mocks")
                                 ],
                                 dependencies: [
                                     .target(name: "ScoreFive"),
                                     .project(target: "FBSnapshotTestCase", path: "../Vendor/FBSnapshotTestCase")
                                 ],
                                 settings: .init(base: [:],
                                                 debug: .settings([:], xcconfig: .relativeToManifest("Config/ScoreFiveTests.xcconfig")),
                                                 release: .settings([:], xcconfig: .relativeToManifest("Config/ScoreFiveTests.xcconfig")),
                                                 defaultSettings: .recommended))
                      ],
                      schemes: [
                          .init(name: "App",
                                shared: true,
                                buildAction: BuildAction(targets: ["ScoreFive"]),
                                testAction: TestAction(targets: ["ScoreFiveTests"]),
                                runAction: RunAction(executable: "ScoreFive",
                                                     arguments: .init(environment: ["FB_REFERENCE_IMAGE_DIR": "$(SOURCE_ROOT)/$(PROJECT_NAME)Tests/ReferenceImages",
                                                                                    "IMAGE_DIFF_DIR": "$(SOURCE_ROOT)/$(PROJECT_NAME)Tests/FailureDiffs",
                                                                                    "AN_ALLOW_ANONYMOUS_ANALYTICS": "YES"])))
                      ])
