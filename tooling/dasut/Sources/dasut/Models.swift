//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShellOut

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

    /// Root tuist
    let tuist: TuistConfiguration
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

    /// Locations to write mocks
    let destinations: [String]
}

/// Test Configuration
struct TestConfiguration: Codable {

    /// Test Device
    let device: String

    /// Test OS
    let os: String

}

/// Tuist Configuration
struct TuistConfiguration: Codable {

    /// Root app directory
    let root: String

    /// Generation options
    let generationOptions: [String]

}
