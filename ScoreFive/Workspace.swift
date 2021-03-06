//
// ScoreFive
// Varun Santhanam
//

import ProjectDescription

let workspace = Workspace(name: "ScoreFive",
                          projects: [
                              "App",
                              "Libraries/Analytics",
                              "Libraries/AppFoundation",
                              "Libraries/FiveUI",
                              "Libraries/Logging",
                              "Vendor/SnapKit",
                              "Vendor/NeedleFoundation",
                              "Vendor/Countly",
                              "Vendor/FBSnapshotTestCase",
                              "Vendor/CombineSchedulers"
                          ],
                          schemes: [
                              .init(name: "ScoreFive",
                                    shared: true,
                                    buildAction: BuildAction(targets: [.project(path: "App", target: "ScoreFive")]),
                                    testAction: TestAction(targets: [
                                        .init(target: .project(path: "App", target: "ScoreFiveTests")),
                                        .init(target: .project(path: "Vendor/NeedleFoundation", target: "NeedleFoundationTests")),
                                        .init(target: .project(path: "Vendor/SnapKit", target: "SnapKitTests")),
                                        .init(target: .project(path: "Vendor/CombineSchedulers", target: "CombineSchedulersTests"))
                                    ]),
                                    runAction: RunAction(executable: .project(path: "App", target: "ScoreFive"),
                                                         arguments: .init(environment: ["FB_REFERENCE_IMAGE_DIR": "$(SOURCE_ROOT)/$(PROJECT_NAME)Tests/ReferenceImages",
                                                                                        "IMAGE_DIFF_DIR": "$(SOURCE_ROOT)/$(PROJECT_NAME)Tests/FailureDiffs",
                                                                                        "AN_ALLOW_ANONYMOUS_ANALYTICS": "YES"])))
                          ],
                          additionalFiles: [])
