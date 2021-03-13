import ProjectDescription

let project = Project(name: "FBSnapshotTestCase",
                      organizationName: "Varun Santhanam",
                      targets: [
                        Target(name: "FBSnapshotTestCase",
                               platform: .iOS,
                               product: .framework,
                               bundleId: "com.varunsanthanam.FBSnapshotTestCase",
                               infoPlist: "FBSnapshotTestCase/Info.plist",
                               sources: ["FBSnapshotTestCase/**"],
                               headers: Headers(public: ["FBSnapshotTestCase/**"],
                                                private: [],
                                                project: []),
                               dependencies: [.xctest]),
                      ])
