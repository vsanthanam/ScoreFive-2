import ProjectDescription

let project = Project(name: "Countly",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                        Target(name: "Countly",
                               platform: .iOS,
                               product: .framework,
                               bundleId: "com.varunsanthanam.Countly",
                               infoPlist: "Countly/Info.plist",
                               sources: ["Countly/Sources/**"],
                               headers: Headers(public: ["Countly/Sources/Public/**"],
                                                private: [],
                                                project: ["Countly/Sources/Project/**"]),
                               dependencies: [],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/Countly.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/Countly.xcconfig")),
                                               defaultSettings: .recommended)),
                        Target(name: "CountlyTests",
                               platform: .iOS,
                               product: .unitTests,
                               bundleId: "com.varunsanthanam.CountlyTests",
                               infoPlist: "CountlyTests/Info.plist",
                               sources: ["CountlyTests/**"],
                               dependencies: [
                                    .target(name: "Countly")
                               ],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/CountlyTests.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/CountlyTests.xcconfig")),
                                               defaultSettings: .recommended))
                      ])
