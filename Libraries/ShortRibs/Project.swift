import ProjectDescription

let project = Project(name: "ShortRibs",
                      organizationName: "Varun Santhanam",
                      targets: [
                          Target(name: "ShortRibs",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.ShortRibs",
                                 infoPlist: "ShortRibs/Info.plist",
                                 sources: ["ShortRibs/**"],
                                 dependencies: []),
                          Target(name: "ShortRibsTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.ShortRibsTests",
                                 infoPlist: "ShortRibsTests/Info.plist",
                                 sources: ["ShortRibsTests/**"],
                                 dependencies: [
                                     .target(name: "ShortRibs"),
                                 ]),
                      ])
