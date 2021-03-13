import ProjectDescription

let project = Project(name: "Analytics",
                      organizationName: "Varun Santhanam",
                      targets: [
                          Target(name: "Analytics",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.Analytics",
                                 infoPlist: "Analytics/Info.plist",
                                 sources: ["Analytics/**"],
                                 dependencies: [
                                     .project(target: "Logging", path: "../Logging"),
                                     .project(target: "Countly", path: "../../Vendor/Countly"),
                                 ]),
                          Target(name: "AnalyticsTests",
                                 platform: .iOS,
                                 product: .unitTests,
                                 bundleId: "com.varunsanthanam.AnalyticsTests",
                                 infoPlist: "AnalyticsTests/Info.plist",
                                 sources: ["AnalyticsTests/**"],
                                 dependencies: [
                                     .target(name: "Analytics"),
                                 ]),
                      ])
