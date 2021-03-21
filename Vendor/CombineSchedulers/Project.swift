import ProjectDescription

let project = Project(name: "CombineSchedulers",
                      organizationName: "Varun Santhanam",
                      settings: .init(base: [:],
                                      debug: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      release: .settings([:], xcconfig: .relativeToManifest("Config/Project.xcconfig")),
                                      defaultSettings: .recommended),
                      targets: [
                        Target(name: "CombineSchedulers",
                               platform: .iOS,
                               product: .framework,
                               bundleId: "com.varunsanthanam.CombineSchedulers",
                               infoPlist: "CombineSchedulers/Info.plist",
                               sources: ["CombineSchedulers/**"],
                               headers: Headers(public: "CombineScheduler/CombineScheduler.h",
                                                private: [],
                                                project: []),
                               dependencies: [],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/CombineSchedulers.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/CombineSchedulers.xcconfig")),
                                               defaultSettings: .recommended)),
                        Target(name: "CombineSchedulersTests",
                               platform: .iOS,
                               product: .unitTests,
                               bundleId: "com.varunsanthanam.CombineSchedulersTests",
                               infoPlist: "CombineSchedulersTests/Info.plist",
                               sources: ["CombineSchedulersTests/**"],
                               dependencies: [
                                    .target(name: "CombineSchedulers")
                               ],
                               settings: .init(base: [:],
                                               debug: .settings([:], xcconfig: .relativeToManifest("Config/CombineSchedulersTests.xcconfig")),
                                               release: .settings([:], xcconfig: .relativeToManifest("Config/CombineSchedulersTests.xcconfig")),
                                               defaultSettings: .recommended))
                      ],
                      schemes: [
                        .init(name: "CombineSchedulers",
                              shared: true,
                              buildAction: BuildAction(targets: ["CombineSchedulers"]),
                              testAction: TestAction(targets: ["CombineSchedulersTests"]))
                      ])
