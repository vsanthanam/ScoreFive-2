//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct SwiftFormatCommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "format", abstract: "Run swiftformat")

    func run() throws {
        let configuration = try fetchConfiguration(on: root)
        do {
            try runSwiftFormat(with: configuration)
            print("Process Complete! 🍻")
        } catch {
            print("Formatting Failed: \((error as! ShellOutError).message)")
            throw error
        }
    }

    // MARK: - API

    @Flag(name: .shortAndLong, help: "Display verbose logging")
    var verbose: Bool = false

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

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

        exclude.forEach { exclude in
            let component = "--exclude" + " " + exclude
            configComponents.append(component)
        }

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
        if verbose {
            print("SwiftFormat Config:")
            print(configToUse)
        }
        print("Formatting files...")
        let command = [Commands.swiftformat(on: root), root, headerCommand].joined(separator: " ")
        if verbose {
            print("Running command \(command)")
        }
        try shellOut(to: command)
        try shellOut(to: .removeFile(from: root + "/.swiftformat"))
    }
}
