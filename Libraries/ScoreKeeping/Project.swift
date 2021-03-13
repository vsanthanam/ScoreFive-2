import ProjectDescription

let project = Project(name: "ScoreKeeping",
                      organizationName: "Varun Santhanam",
                      targets: [
                          Target(name: "ScoreKeeping",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.ScoreKeeping",
                                 infoPlist: "ScoreKeeping/Info.plist",
                                 sources: ["ScoreKeeping/**"],
                                 dependencies: [
                                     /* Target dependencies can be defined here */
                                     /* .framework(path: "framework") */
                                 ]),
                          Target(name: "ScoreKeepingTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.ScoreKeepingTests",
                                 infoPlist: "ScoreKeepingTests/Info.plist",
                                 sources: ["ScoreKeepingTests/**"],
                                 dependencies: [
                                     .target(name: "ScoreKeeping"),
                                 ]),
                      ])
