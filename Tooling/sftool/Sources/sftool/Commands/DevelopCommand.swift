//
// ScoreFive
// Varun Santhanam
//

import Foundation

import ArgumentParser
import Foundation
import ShellOut

struct DevelopCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "develop",
                                                    abstract: "Generate the project")

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Don't automatically open Xcode")
    var dontOpenXcode: Bool = false

    @Option(name: .shortAndLong, help: "The file to check")
    var fileCondition: String?
    
    func run() throws {
        if let fileCondition = fileCondition {
            if fileCondition.contains("Project.swift") || fileCondition.contains("Workspace.swift") {
                do {
                    try Commands.generate(on: root)
                } catch {
                    print("Error:1 Workspace cannot be generated!")
                }
            }
        } else {
            try? Commands.killXcode()
            try Commands.generate(on: root)
            if !dontOpenXcode {
                try Commands.openWorkspace(on: root)
            }
        }
    }
}
