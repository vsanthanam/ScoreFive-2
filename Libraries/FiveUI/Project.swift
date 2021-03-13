import ProjectDescription

let project = Project(name: "FiveUI",
                      organizationName: "Varun Santhanam",
                      targets: [
                          Target(name: "FiveUI",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.FiveUI",
                                 infoPlist: "FiveUI/Info.plist",
                                 sources: ["FiveUI/**"],
                                 dependencies: [
                                     .project(target: "SnapKit", path: "../../Vendor/SnapKit"),
                                 ]),
                          Target(name: "FiveUITests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.FiveUITests",
                                 infoPlist: "FiveUITests/Info.plist",
                                 sources: ["FiveUITests/**"],
                                 dependencies: [
                                     .target(name: "FiveUI"),
                                 ]),
                      ])
