import ProjectDescription

let project = Project(name: "Countly",
                      organizationName: "Varun Santhanam",
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
                               dependencies: [
                                    /* Target dependencies can be defined here */
                                    /* .framework(path: "framework") */
                                ]),
                        Target(name: "CountlyTests",
                               platform: .iOS,
                               product: .unitTests,
                               bundleId: "com.varunsanthanam.CountlyTests",
                               infoPlist: "CountlyTests/Info.plist",
                               sources: ["CountlyTests/**"],
                               dependencies: [
                                    .target(name: "Countly")
                               ])
                      ])
