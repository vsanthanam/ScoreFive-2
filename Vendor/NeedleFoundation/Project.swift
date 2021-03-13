import ProjectDescription

let project = Project(name: "NeedleFoundation",
                      organizationName: "Varun Santhanam",
                      targets: [
                        Target(name: "NeedleFoundation",
                               platform: .iOS,
                               product: .framework,
                               bundleId: "com.varunsanthanam.NeedleFoundation",
                               infoPlist: "NeedleFoundation/Info.plist",
                               sources: ["NeedleFoundation/**"],
                               dependencies: [
                                    /* Target dependencies can be defined here */
                                    /* .framework(path: "framework") */
                                ]),
                        Target(name: "NeedleFoundationTests",
                               platform: .iOS,
                               product: .unitTests,
                               bundleId: "com.varunsanthanam.NeedleFoundationTests",
                               infoPlist: "NeedleFoundationTests/Info.plist",
                               sources: ["NeedleFoundationTests/**"],
                               dependencies: [
                                    .target(name: "NeedleFoundation")
                               ])
                      ])
