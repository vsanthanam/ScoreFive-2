//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut
import Yams

struct LintCommand: ParsableCommand, DasutCommand {

    // MARK: - API

    struct LintResult: CustomStringConvertible {
        enum Source: String {
            case swiftlint
            case swiftformat
        }

        enum Level: String {
            case warning
            case error
        }

        let message: String
        let file: String
        let line: Int
        let col: Int
        let level: Level
        let source: Source

        var description: String {
            "[\(level.rawValue)] \(file) at line \(line):\(col) — \(message)"
        }
    }

    @Option(name: .long, help: "File to lint")
    var input: String?

    @Option(name: .long, help: "Location of the score five repo")
    var repoRoot: String = FileManager.default.currentDirectoryPath

    @Option(name: .long, help: "Location of the configuration file")
    var toolConfiguration: String = ".dasut-config"

    @Flag(name: .long, help: "Display verbose logging")
    var trace: Bool = false

    @Flag(name: .long, help: "Fix errors where able")
    var autofix: Bool = false

    @Flag(name: .long, help: "For internal use by arcanist. Do not use.")
    var arclint: Bool = false

    // MARK: - ParsableCommand

    static let configuration: CommandConfiguration = .init(commandName: "lint",
                                                           abstract: "Lint .swift files",
                                                           version: "2.0")

    // MARK: - DasutCommand

    func action() throws {

        guard let configuration = try fetchConfiguration(on: repoRoot, location: toolConfiguration) else {
            fatalError()
        }

        wipeConfig()

        if autofix, !arclint {
            try runSwiftLint(with: configuration, fix: true)
            try runSwiftFormat(with: configuration, fix: true)
            wipeConfig()
        }

        let lintResults = try runSwiftLint(with: configuration, fix: false)
        let formatResults = try runSwiftFormat(with: configuration, fix: false)

        let results = (lintResults + formatResults).sorted { lhs, rhs in
            lhs.file < rhs.file
        }

        
        
        for result in results {
            if arclint {
                let formatted = "\(result.level.rawValue):\(result.line):\(result.col) \(result.message) [\(result.source.rawValue)]"
                write(message: formatted)
            } else {
                switch result.level {
                case .warning:
                    warn(message: result.description, withColor: .yellow)
                case .error:
                    warn(message: result.description, withColor: .red)
                }
            }
        }

        wipeConfig()

        if arclint {
            complete(with: nil)
            return
        }

        if !results.isEmpty {
            let warnings = results.filter { $0.level == .warning }.count
            let errors = results.filter { $0.level == .error }.count
            if autofix {
                throw CustomDasutError(message: "Found \(warnings) warnings, \(errors) errors after fixing")
            } else {
                throw CustomDasutError(message: "Found \(warnings) warnings, \(errors) errors")
            }
        } else {
            if autofix {
                complete(with: "No errors found after fixing! 🍻")
            } else {
                complete(with: "No errors found! 🍻")
            }
        }
    }

    // MARK: - Private

    private func wipeConfig() {
        _ = try? shellOut(to: "rm .swiftlint.yml", at: repoRoot)
        _ = try? shellOut(to: "rm .swiftformat", at: repoRoot)
    }

    @discardableResult
    private func runSwiftLint(with configuration: ToolConfiguration, fix: Bool) throws -> [LintResult] {
        struct SwiftLintConfig: Codable {
            var excluded: [String] = []
            var disabled_rules: [String] = []
        }

        var config = SwiftLintConfig()
        let exclude = (configuration.swiftlint.excludeDirs + [configuration.vendorCodePath, configuration.diGraphPath] + configuration.mockolo.destinations).map { repoRoot + "/" + $0 }
        config.excluded = exclude
        config.disabled_rules = configuration.swiftlint.disabledRules
        let encoder = YAMLEncoder()
        let yaml = try encoder.encode(config)
        if trace, !arclint {
            write(message: "SwifLint Configuration")
            write(message: yaml)
        }
        let echo = "echo \"\(yaml)\" >> .swiftlint.yml"
        try shellOut(to: echo, at: repoRoot)
        var command = "bin/swiftlint/swiftlint"
        if fix {
            command = [command, "--path", (input ?? repoRoot), "--fix", "--strict"].joined(separator: " ")
        } else {
            command = [command, "--path", (input ?? repoRoot), "--strict"].joined(separator: " ")
        }
        if trace, !arclint {
            write(message: "Running Command: \(command)")
        }
        do {
            try shellOut(to: command, at: repoRoot)
            return []
        } catch {
            guard let error = error as? ShellOutError else {
                throw CustomDasutError(message: "Linting failed!")
            }
            var output = [LintResult]()
            error.output
                .split(separator: "\n")
                .filter { $0.hasPrefix("/") }
                .map { output -> LintResult in
                    let comps = output.split(separator: ":")
                    let file = comps[0]
                    let line = Int(comps[1])!
                    let col = Int(comps[2])!
                    let level = LintResult.Level(rawValue: String(comps[3].dropFirst()))!
                    let message = comps[4].dropFirst()
                    return LintResult(message: .init(message),
                                      file: String(file),
                                      line: line,
                                      col: col,
                                      level: level,
                                      source: .swiftlint)
                }
                .forEach { line in
                    output.append(line)
                }
            return output
        }
    }

    @discardableResult
    private func runSwiftFormat(with configuration: ToolConfiguration, fix: Bool) throws -> [LintResult] {
        var configComponents: [String] = .init()
        if !configuration.swiftformat.disableRules.isEmpty {
            let disable = "--disable" + " " + configuration.swiftformat.disableRules.joined(separator: ",")
            configComponents.append(disable)

        }
        if !configuration.swiftformat.enableRules.isEmpty {
            let enable = "--enable" + " " + configuration.swiftformat.enableRules.joined(separator: ",")
            configComponents.append(enable)
        }

        let exclude = [configuration.vendorCodePath] + [configuration.diGraphPath] + configuration.mockolo.destinations + configuration.swiftformat.excludeDirs

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
        let echo = "echo \"\(swiftformat)\" >> .swiftformat"
        try shellOut(to: echo)
        let configToUse = try shellOut(to: .readFile(at: ".swiftformat"), at: repoRoot)
        if trace, !arclint {
            write(message: "SwiftFormat config:")
            write(message: configToUse)
        }
        let command: String
        if fix {
            command = ["bin/swiftformat/swiftformat", input ?? repoRoot, headerCommand].joined(separator: " ")
        } else {
            command = ["bin/swiftformat/swiftformat", "--lint", input ?? repoRoot, headerCommand].joined(separator: " ")
        }
        if trace, !arclint {
            write(message: "Running Command: \(command)")
        }
        do {
            try shellOut(to: command, at: repoRoot)
            return []
        } catch {
            guard let error = error as? ShellOutError else {
                throw CustomDasutError(message: "Linting failed!")
            }
            var output = [LintResult]()
            error.message
                .split(separator: "\n")
                .filter { $0.hasPrefix("/") }
                .map { output -> LintResult in
                    let comps = output.split(separator: ":")
                    let file = comps[0]
                    let line = Int(comps[1])!
                    let col = Int(comps[2])!
                    let level = LintResult.Level(rawValue: String(comps[3].dropFirst()))!
                    let message = comps[4].dropFirst()
                    return LintResult(message: .init(message),
                                      file: String(file),
                                      line: line,
                                      col: col,
                                      level: level,
                                      source: .swiftformat)
                }
                .forEach { line in
                    output.append(line)
                }
            return output
        }
    }
}
