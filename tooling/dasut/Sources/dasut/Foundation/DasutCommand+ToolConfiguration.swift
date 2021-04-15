//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShellOut

/// Errors from parsing the configuration file
enum ConfigurationError: Error, DasutError {

    /// `.sftool-config.json` could not be parsed into a `Configuration object`
    /// - seeAlso: `Configuration`
    case decodingFailed(error: Error)

    /// The error message
    var message: String {
        switch self {
        case let .decodingFailed(error):
            return "Malformed configuration file -- \(error)"
        }
    }
}

extension DasutCommand {

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
