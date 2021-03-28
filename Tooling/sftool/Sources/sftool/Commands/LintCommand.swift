//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut
import Yams

enum LintError: Error {
    case invalidConfiguration
    case lintFailed
    case unknownFailuer
}

struct LintCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "lint", abstract: "Lint swift code")

    func run() throws {
        if test, (fix || arclint) {
            throw LintError.invalidConfiguration
        }
        let configuration = try fetchConfiguration(on: root)

        var lintOutput = [String]()
        do {
            try runSwiftFormat(with: configuration)
        } catch {
            guard let message = (error as? ShellOutError)?.message else {
                throw LintError.unknownFailuer
            }
            message
                .split(separator: "\n")
                .filter { $0.hasPrefix("/") }
                .map { output in
                    if arclint {
                        let comps = output.split(separator: ":")
                        return "warning:\(comps[1]) \(comps[4])(swiftformat)"
                    } else {
                        return String(output) + "(swiftformat)"
                    }
                }
                .forEach { line in
                    lintOutput.append(line)
                }
        }
        do {
            try runSwiftLint(with: configuration)
        } catch {
            guard let message = (error as? ShellOutError)?.output else {
                throw LintError.unknownFailuer
            }
            message
                .split(separator: "\n")
                .filter { $0.hasPrefix("/") }
                .map { output in
                    if arclint {
                        let comps = output.split(separator: ":")
                        return "warning:\(comps[1]) \(comps[4])(swiftlint)"
                    } else {
                        return String(output) + "(swiftlint)"
                    }
                }
                .forEach { line in
                    lintOutput.append(line)
                }
        }

        wipeConfigurations()

        if !lintOutput.isEmpty {
            if test {
                throw LintError.lintFailed
            } else {
                lintOutput.forEach { print($0) }
            }
        }
    }

    // MARK: - API

    @Flag(name: .shortAndLong, help: "Display verbose logging")
    var verbose: Bool = false

    @Flag(name: .shortAndLong, help: "Fix errors")
    var fix: Bool = false

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Arc Lint")
    var arclint: Bool = false

    @Option(name: .shortAndLong, help: "File or directory to lint")
    var input: String?

    @Flag(name: .shortAndLong, help: "Fail it code has errors. This option cannot be used with --arclint or with --fix")
    var test: Bool = false

    // MARK: - Private

    private func wipeConfigurations() {
        _ = try? shellOut(to: .removeFile(from: root + "/.swiftformat"))
        _ = try? shellOut(to: .removeFile(from: root + "/.swiftlint.yml"))
    }

    private func runSwiftFormat(with configuration: ToolConfiguration) throws {
        var configComponents: [String] = .init()
        if !configuration.swiftformat.disableRules.isEmpty {
            let disable = "--disable" + " " + configuration.swiftformat.disableRules.joined(separator: ",")
            configComponents.append(disable)

        }
        if !configuration.swiftformat.enableRules.isEmpty {
            let enable = "--enable" + " " + configuration.swiftformat.enableRules.joined(separator: ",")
            configComponents.append(enable)
        }

        let exclude = [configuration.vendorCodePath] + [configuration.diGraphPath] + [configuration.mockPath] + configuration.swiftformat.excludeDirs

        exclude
            .forEach { exclude in
                let component = "--exclude" + " " + exclude
                configComponents.append(component)
            }

        configComponents.append("--swiftversion \(configuration.swiftformat.swiftVersion)")

        let header = """
        //
        // ScoreFive
        // Varun Santhanam
        //
        """
        let headerCommand = "--header \"\(header)\""
        let swiftformat = configComponents.joined(separator: "\n")
        let echo = "echo \"\(swiftformat)\" >> \(root)/.swiftformat"
        try shellOut(to: echo)
        let configToUse = try shellOut(to: .readFile(at: root + "/.swiftformat"))
        if verbose, !arclint {
            print("SwiftFormat config:")
            print(configToUse)
        }
        let command: String
        if fix {
            command = [Commands.swiftformat(on: root), input ?? root, headerCommand].joined(separator: " ")
        } else {
            command = [Commands.swiftformat(on: root), "--lint", input ?? root, headerCommand].joined(separator: " ")
        }
        if verbose {
            print("Running Command: \(command)")
        }
        try shellOut(to: command)
    }

    private func runSwiftLint(with configuration: ToolConfiguration) throws {

        struct SwiftLintConfig: Codable {
            var excluded: [String] = []
            var disabled_rules: [String] = []
        }

        var config = SwiftLintConfig()
        let exclude = (configuration.swiftlint.excludeDirs + [configuration.vendorCodePath, configuration.diGraphPath, configuration.mockPath]).map { root + "/" + $0 }
        config.excluded = exclude
        config.disabled_rules = configuration.swiftlint.disabledRules

        let encoder = YAMLEncoder()
        let yaml = try encoder.encode(config)
        if verbose {
            print("SwiftLint Configuration:")
            print(yaml)
        }
        let echo = "echo \"\(yaml)\" >> \(root)/.swiftlint.yml"
        try shellOut(to: echo)
        var command = Commands.swiftlint(on: root)
        if fix {
            command = [command, "--path", (input ?? root), "--fix", "--strict"].joined(separator: " ")
        } else {
            command = [command, "--path", (input ?? root), "--strict"].joined(separator: " ")
        }
        if verbose {
            print("Running Command: \(command)")
        }
        try shellOut(to: command)
    }
}
