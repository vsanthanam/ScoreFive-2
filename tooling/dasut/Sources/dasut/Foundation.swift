//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

protocol DasutError {
    var message: String { get }
}

struct CustomDasutError: Error, DasutError {
    let message: String
}

/// Errors from parsing the configuration file
enum ConfigurationError: Error, DasutError {

    /// `.sftool-config.json` could not be parsed into a `Configuration object`
    /// - seeAlso: `Configuration`
    case decodingFailed(error: Error)

    /// The error message
    var message: String {
        switch self {
        case let .decodingFailed(error):
            return "Malformed configuration file -- \(error.localizedDescription)"
        }
    }
}

protocol DasutCommand {
    func action() throws
}

extension DasutCommand {

    // MARK: - API

    func write(message: String, withColor color: Color? = nil) {
        if let color = color {
            print(message.withColor(color), to: &io.standardOut)
        } else {
            print(message, to: &io.standardOut)
        }
    }

    func complete(with message: String? = "Success! 🍻") {
        if let message = message {
            print(message.withColor(.green), to: &io.standardOut)
            Darwin.exit(EXIT_SUCCESS)
        }
    }

    @discardableResult
    func shell(_ command: ShellOutCommand, at path: String = ".", errorMessage: String? = nil, verbose: Bool = false) throws -> String {
        do {
            if verbose {
                write(message: command.string)
            }
            return try shellOut(to: command,
                                at: path,
                                outputHandle: verbose ? io.stdout : nil,
                                errorHandle: verbose ? io.stderr : nil)
        } catch {
            throw CustomDasutError(message: errorMessage ?? "Command Failed!")
        }
    }

    @discardableResult
    func shell(script: String, at path: String = ".", errorMessage: String? = nil, verbose: Bool = false) throws -> String {
        try shell(.init(string: script),
                  at: path,
                  errorMessage: errorMessage,
                  verbose: verbose)
    }

    func execute(_ action: () throws -> Void) throws {
        do {
            try action()
        } catch {
            if let error = error as? DasutError {
                let message = error.message.withColor(.red)
                print(message, to: &io.standardError)
                Darwin.exit(EXIT_FAILURE)
            } else {
                throw error
            }
        }
    }

    func fetchConfiguration(on root: String, location: String = ".dasut-config") throws -> ToolConfiguration? {
        guard let file = try? shellOut(to: .readFile(at: location), at: root) else {
            return nil
        }

        do {
            let jsonData = file.data(using: .utf8)!
            let decoder = JSONDecoder()
            let config = try decoder.decode(ToolConfiguration.self, from: jsonData)
            return config
        } catch {
            throw ConfigurationError.decodingFailed(error: error)
        }
    }
}

extension ParsableCommand where Self: DasutCommand {

    func run() throws {
        try execute(action)
    }

}

enum Color: Int {
    case red = 31
    case green = 32
    case yellow = 33
}

private extension String {
    func withColor(_ color: Color) -> String {
        "\u{1B}[\(color.rawValue)m\(self)\u{1B}[0m"
    }
}

enum io {

    static var standardError = StandardError()

    static var standardOut = StandardOut()

    private(set) static var stderr = FileHandle.standardError

    private(set) static var stdout = FileHandle.standardOutput

    struct StandardError: TextOutputStream {
        func write(_ string: String) {
            guard let data = string.data(using: .utf8) else {
                return // encoding failure
            }
            stderr.write(data)
        }
    }

    struct StandardOut: TextOutputStream {
        func write(_ string: String) {
            guard let data = string.data(using: .utf8) else {
                return // encoding failure
            }
            stdout.write(data)
        }
    }
}
