import ProjectDescription

let project = Project(name: "NeedleFoundation",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                        Target(name: "NeedleFoundation",
                               platform: .iOS,
                               product: .framework,
                               bundleId: "com.varunsanthanam.NeedleFoundation",
                               infoPlist: "NeedleFoundation/Info.plist",
                               sources: ["NeedleFoundation/**"],
                               dependencies: [],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/NeedleFoundation.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/NeedleFoundation.xcconfig")),
                                               defaultSettings: .recommended)),
                        Target(name: "NeedleFoundationTests",
                               platform: .iOS,
                               product: .unitTests,
                               bundleId: "com.varunsanthanam.NeedleFoundationTests",
                               infoPlist: "NeedleFoundationTests/Info.plist",
                               sources: ["NeedleFoundationTests/**"],
                               dependencies: [
                                    .target(name: "NeedleFoundation")
                               ],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/NeedleFoundationTests.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/NeedleFoundationTests.xcconfig")),
                                               defaultSettings: .recommended))
                      ])
