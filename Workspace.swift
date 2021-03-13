import ProjectDescription

let workspace = Workspace(name: "Workspace",
                          projects: [
                              "App",
                              "Libraries/Analytics",
                              "Libraries/FiveUI",
                              "Libraries/Logging",
                              "Libraries/ScoreKeeping",
                              "Vendor/SnapKit",
                              "Vendor/NeedleFoundation",
                              "Vendor/Countly",
                              "Vendor/FBSnapshotTestCase"
                          ],
                          schemes: [],
                          additionalFiles: [
                              "README.md",
                              ".sftool-config",
                              "LICENSE",
                              "Workspace.swift",
                          ])
