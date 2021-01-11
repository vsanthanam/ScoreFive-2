//
//  File.swift
//
//
//  Created by Varun Santhanam on 1/10/21.
//

import ArgumentParser
import Foundation
import ShellOut
import Yams

struct SwiftLintCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "lint", abstract: "Run swiftlint")

    func run() throws {
        let configuration = try fetchConfiguration(on: root)
        do {
            try runSwiftLint(with: configuration)
            print("Process Complete! 🍻")
        } catch {
            print("\((error as! ShellOutError).message)")
            throw error
        }
    }

    // MARK: - API

    @Flag(name: .shortAndLong, help: "Verbose logging")
    var verbose: Bool = false

    @Flag(name: .shortAndLong, help: "Show warnings and errors, instead of just errors")
    var warnings: Bool = false

    @Flag(name: .shortAndLong, help: "Fix where able")
    var fix: Bool = false

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    private func runSwiftLint(with configuration: Configuration) throws {

        struct SwiftLintConfig: Codable {
            var excluded: [String] = []
            var included: [String] = []
            var disabled_rules: [String] = []
        }

        var config = SwiftLintConfig()
        let exclude = (configuration.swiftlint.excludeDirs + [configuration.vendorCodePath, configuration.diGraphPath, configuration.mockPath]).map { root + "/" + $0 }
        config.excluded = exclude
        config.included = [root + "/" + configuration.featureCodePath]
        config.disabled_rules = configuration.swiftlint.disabledRules

        let encoder = YAMLEncoder()
        let yaml = try encoder.encode(config)
        if verbose {
            print("SwiftLint Configuration:")
            print(yaml)
        }
        let echo = "echo \"\(yaml)\" >> \(root)/.swiftlint.yml"
        try shellOut(to: echo)
        var command = "swiftlint"
        if fix {
            command = [command, "autocorrect"].joined(separator: " ")
        }
        let result = try shellOut(to: command)
        if warnings {
            print(result)
        }
        try shellOut(to: .removeFile(from: root + "/.swiftlint.yml"))
    }
}
