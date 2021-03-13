import ProjectDescription

let project = Project(name: "SnapKit",
                      organizationName: "Varun Santhanam",
                      targets: [
                        Target(name: "SnapKit",
                               platform: .iOS,
                               product: .framework,
                               bundleId: "com.varunsanthanam.SnapKit",
                               infoPlist: "SnapKit/Info.plist",
                               sources: ["SnapKit/**"],
                               dependencies: [
                                    /* Target dependencies can be defined here */
                                    /* .framework(path: "framework") */
                                ]),
                        Target(name: "SnapKitTests",
                               platform: .iOS,
                               product: .unitTests,
                               bundleId: "com.varunsanthanam.SnapKitTests",
                               infoPlist: "SnapKitTests/Info.plist",
                               sources: ["SnapKitTests/**"],
                               dependencies: [
                                    .target(name: "SnapKit")
                               ])
                      ])
