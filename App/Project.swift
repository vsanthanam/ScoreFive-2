import ProjectDescription

let project = Project(name: "ScoreFive",
                      organizationName: "Varun Santhanam",
                      targets: [
                          Target(name: "ScoreFive",
                                 platform: .iOS,
                                 product: .app,
                                 bundleId: "com.varunsanthanam.ScoreFive",
                                 infoPlist: "ScoreFive/Info.plist",
                                 sources: ["ScoreFive/Src/**"],
                                 resources: ["ScoreFive/Resources/**"],
                                 dependencies: [
                                     .project(target: "Analytics", path: "../Libraries/Analytics"),
                                     .project(target: "FiveUI", path: "../Libraries/FiveUI"),
                                     .project(target: "Logging", path: "../Libraries/Logging"),
                                     .project(target: "ScoreKeeping", path: "../Libraries/ScoreKeeping"),
                                     .project(target: "ShortRibs", path: "../Libraries/ShortRibs"),
                                     .project(target: "SnapKit", path: "../Vendor/SnapKit"),
                                     .project(target: "NeedleFoundation", path: "../Vendor/NeedleFoundation"),
                                     .project(target: "Countly", path: "../Vendor/Countly"),
                                 ],
                                 coreDataModels: [
                                     CoreDataModel("ScoreFive/ScoreFive.xcdatamodeld", currentVersion: "ScoreFive"),
                                 ]),
                          Target(name: "ScoreFiveTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.ScoreFiveTests",
                                 infoPlist: "ScoreFiveTests/Info.plist",
                                 sources: ["ScoreFiveTests/**"],
                                 dependencies: [
                                     .target(name: "ScoreFive"),
                                     .project(target: "FBSnapshotTestCase", path: "../Vendor/FBSnapshotTestCase")
                                 ]),
                      ])
