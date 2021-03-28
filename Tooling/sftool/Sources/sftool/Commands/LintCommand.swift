//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct LintCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "lint", abstract: "Lint swift code")

    func run() throws {
        if ci {
            precondition(!fix)
            precondition(!arclint)
        }
        let configuration = try fetchConfiguration(on: root)
        do {
            try runSwiftFormat(with: configuration)
            if fix {
                print("🍻 Files Fixed!")
            } else if !arclint {
                print("🍻 No Errors!")
            }
        } catch {
            if fix || ci {
                throw error
            } else {
                let message = (error as! ShellOutError).message
                message
                    .split(separator: "\n")
                    .filter { $0.hasPrefix("/") }
                    .map { output in
                        if arclint {
                            let comps = output.split(separator: ":")
                            return "warning:\(comps[1]) \(comps[4])"
                        } else {
                            return output
                        }
                    }
                    .forEach { print($0) }
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

    @Flag(name: .shortAndLong, help: "Run in CI")
    var ci: Bool = false

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
        try shellOut(to: .removeFile(from: root + "/.swiftformat"))
    }
}
