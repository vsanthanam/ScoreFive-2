import ProjectDescription

let project = Project(name: "Logging",
                      organizationName: "Varun Santhanam",
                      targets: [
                          Target(name: "Logging",
                                 platform: .iOS,
                                 product: .framework,
                                 bundleId: "com.varunsanthanam.Logging",
                                 infoPlist: "Logging/Info.plist",
                                 sources: ["Logging/**"],
                                 dependencies: [
                                     
                                 ]),
                      ])
