//
// ScoreFive
// Varun Santhanam
//

import ArgumentParser
import Foundation
import ShellOut

struct sftool: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(
        abstract: "A command line utility for the ScoreFive iOS repo",
        subcommands: [GenerateCommand.self,
                      LintCommand.self,
                      BootstrapCommand.self,
                      AnalyticsCommand.self,
                      TestCommand.self,
                      DevelopCommand.self]
    )
}

enum Commands {
    static func generateDependencyGraph(_ root: String, diCodePath: String, diGraphPath: String, verbose: Bool) throws {
        let needleInput = root + "/" + diCodePath
        let dependencyGraph = root + "/" + diGraphPath
        if verbose {
            print("Input Paths:")
            print(needleInput)
            print("Output Path:")
            print(dependencyGraph)
        }
        let command = "export SOURCEKIT_LOGGING=0 && \(needle(on: root)) generate \(dependencyGraph) \(needleInput)"
        if verbose {
            print("Running command \(command)")
        }
        try shellOut(to: command)
    }

    static func generateMocks(_ root: String, featureCodePath: String, libraryCodePath: String, mockPath: String, testableImports: [String], verbose: Bool) throws {
        let featureCode = root + "/" + featureCodePath
        let libraryCode = root + "/" + libraryCodePath
        let mocks = root + "/" + mockPath
        if verbose {
            print("Input Paths:")
            print(featureCode)
            print(libraryCode)
            print("Output Path:")
            print(mocks)
        }
        var command = "\(mockolo(on: root)) -s \(featureCode) \(libraryCode) -d \(mocks)"
        if !testableImports.isEmpty {
            if verbose {
                print("Adding Testable Imports")
                testableImports.forEach { print($0) }
            }
            command.append(" ")
            command.append((["-i"] + testableImports).joined(separator: " "))
        }
        if verbose {
            print("Running command \(command)")
        }
        try shellOut(to: command)
    }

    static func writeAnalyticsConfiguration(_ root: String, tuistRoot: String, config: AnalyticsConfig = .empty) throws {
        let data = try JSONEncoder().encode(config)
        let targetPath = "/App/ScoreFive/Resources/analytics_config.json"
        try shellOut(to: .removeFile(from: root + "/" + tuistRoot + targetPath))
        try NSData(data: data).write(toFile: root + "/" + tuistRoot + targetPath)
    }

    static func readAnalyticsConfiguration(_ root: String, tuistRoot: String) throws -> AnalyticsConfig {
        func readFile() throws -> String {
            do {
                return try shellOut(to: .readFile(at: root + "/" + tuistRoot + "/App/ScoreFive/Resources/analytics_config.json"))
            } catch {
                // swiftlint:disable:next force_cast
                throw ConfigurationError.notFound(error: error as! ShellOutError)
            }
        }

        let file = try readFile()

        let jsonData = file.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try decoder.decode(AnalyticsConfig.self, from: jsonData)
    }

    static func runTests(_ root: String, tuistRoot: String, name: String, os: String) throws -> String {
        try tuist(on: root, tuistRoot: tuistRoot) {
            try killXcode()
            try generate(on: root, tuistRoot: tuistRoot)
            return try shellOut(to: "xcodebuild -workspace \(root)/\(tuistRoot)/ScoreFive.xcworkspace -sdk iphonesimulator -scheme ScoreFive -destination 'platform=iOS Simulator,name=\(name),OS=\(os)' test")
        }
    }

    static func killXcode() throws {
        try shellOut(to: "killall Xcode")
    }

    static func generate(on root: String, tuistRoot: String) throws {
        try tuist(on: root, tuistRoot: tuistRoot) {
            let command = root + "/bin/tuist/tuist"
            let tuistDir = root + "/" + tuistRoot
            return try shellOut(to: "\(command) generate --path \(tuistDir)")
        }
    }

    static func openWorkspace(on root: String, tuistRoot: String) throws {
        let path = root + "/" + tuistRoot + "/ScoreFive.xcworkspace"
        try shellOut(to: "open \(path)")
    }

    static func swiftlint(on root: String) -> String {
        root + "/bin/swiftlint/swiftlint"
    }

    static func swiftformat(on root: String) -> String {
        root + "/bin/swiftformat/swiftformat"
    }

    fileprivate static func needle(on root: String) -> String {
        root + "/bin/needle/needle"
    }

    fileprivate static func mockolo(on root: String) -> String {
        root + "/bin/mockolo/mockolo"
    }

    @discardableResult
    fileprivate static func tuist(on root: String, tuistRoot: String, action: () throws -> String) throws -> String {
        let settings = """
        import ProjectDescription

        let config = Config(
            generationOptions: [
                .disableAutogeneratedSchemes,
                .disableSynthesizedResourceAccessors,
            ]
        )
        """
        let dir = root + "/" + tuistRoot + "/Tuist"
        let path = dir + "/Config.swift"
        _ = try? shellOut(to: "rm -rf \(dir)")
        try shellOut(to: "mkdir \(dir)")
        try shellOut(to: "echo \"\(settings)\" > \(path)")
        let rv = try action()
        _ = try? shellOut(to: "rm -rf \(dir)")
        return rv
    }
}

sftool.main()
