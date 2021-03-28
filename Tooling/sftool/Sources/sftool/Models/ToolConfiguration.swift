//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShellOut

/// Errors from parsing the configuration file
enum ConfigurationError: Error {
    /// `.sftool-config.json` was not found at the provided root directory
    case notFound(error: ShellOutError)

    /// `.sftool-config.json` could not be parsed into a `Configuration object`
    /// - seeAlso: `Configuration`
    case decodingFailed(error: Error)

    /// The error message
    var message: String {
        switch self {
        case let .decodingFailed(error):
            return "Malformed configuration file -- \(error.localizedDescription)"
        case let .notFound(error):
            return "Configuration file not found -- \(error.localizedDescription)"
        }
    }
}

/// Fetch the configuration file in the provided root directory`
/// - Parameter root: The root directory of the ScoreFive repo to search for teh config file for
/// - Throws: The error when finding or parsing the repo
/// - Returns: The configuration file
func fetchConfiguration(on root: String) throws -> ToolConfiguration {

    func readFile() throws -> String {
        do {
            return try shellOut(to: .readFile(at: root + "/.sftool-config"))
        } catch {
            // swiftlint:disable:next force_cast
            throw ConfigurationError.notFound(error: error as! ShellOutError)
        }
    }

    let file = try readFile()

    do {
        let jsonData = file.data(using: .utf8)!
        let decoder = JSONDecoder()
        let config = try decoder.decode(ToolConfiguration.self, from: jsonData)
        return config
    } catch {
        throw ConfigurationError.decodingFailed(error: error)
    }
}

/// The configuration object model
struct ToolConfiguration: Codable {

    /// SwiftFormat configuration
    let swiftformat: SwiftFormatConfiguration

    /// SwiftLint configuration
    let swiftlint: SwiftLintConfiguration

    /// Mockolo configuration
    let mockolo: MockoloConfiguration

    /// Test configuration
    let testConfig: TestConfiguration

    /// Mock source path
    let mockPath: String

    /// DI graph source path
    let diGraphPath: String

    /// Path to source that consume the DI graoh
    let diCodePath: String

    /// Vendor code path
    let vendorCodePath: String

    /// Feature code path
    let featureCodePath: String

    /// Library code path
    let libraryCodePath: String
}

/// SwiftFormat configuration
struct SwiftFormatConfiguration: Codable {

    /// Rules to enable
    let enableRules: [String]

    /// Rules to disable
    let disableRules: [String]

    /// Directories to exclude
    let excludeDirs: [String]

    /// Swift version
    let swiftVersion: String
}

struct SwiftLintConfiguration: Codable {

    /// Directories to exclude
    let excludeDirs: [String]

    /// Disabled rules
    let disabledRules: [String]

    /// Opt-In Rules
    let optInRules: [String]
}

/// Mockolo Configuration
struct MockoloConfiguration: Codable {

    /// @testable modules to import
    let testableImports: [String]
}

/// Test Configuration
struct TestConfiguration: Codable {

    /// Test Device
    let device: String

    /// Test OS
    let os: String

}
