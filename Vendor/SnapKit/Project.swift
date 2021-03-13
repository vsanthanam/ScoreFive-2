import ProjectDescription

let project = Project(name: "SnapKit",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                        Target(name: "SnapKit",
                               platform: .iOS,
                               product: .framework,
                               bundleId: "com.varunsanthanam.SnapKit",
                               infoPlist: "SnapKit/Info.plist",
                               sources: ["SnapKit/**"],
                               dependencies: [],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/SnapKit.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/SnapKit.xcconfig")),
                                               defaultSettings: .recommended)),
                        Target(name: "SnapKitTests",
                               platform: .iOS,
                               product: .unitTests,
                               bundleId: "com.varunsanthanam.SnapKitTests",
                               infoPlist: "SnapKitTests/Info.plist",
                               sources: ["SnapKitTests/**"],
                               dependencies: [
                                    .target(name: "SnapKit")
                               ],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/SnapKitTests.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/SnapKitTests.xcconfig")),
                                               defaultSettings: .recommended))
                      ])
