//
//  Mocks.swift
//
//
//  Created by Varun Santhanam on 1/9/21.
//

import ArgumentParser
import Foundation
import ShellOut

struct GenerateMocks: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "mocks",
                                                    abstract: "Generate Mocks with Mockolo")

    func run() throws {
        let config = try fetchConfiguration(on: root)
        do {
            try generateMocks(with: config)
            print("Process Complete! 🍻")
        } catch {
            print("Mockolo Failed: \((error as! ShellOutError).message)")
            throw error
        }
    }

    // MARK: - API

    enum GenerateMocksError: Error {
        case mockoloError(_ error: ShellOutError)

        var message: String {
            switch self {
            case let .mockoloError(error):
                return "Mockolo Failed: \(error.message)"
            }
        }
    }

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    @Flag(name: .shortAndLong, help: "Verbose Logging")
    var verbose: Bool = false

    // MARK: - Private

    private func generateMocks(with configuration: Configuration) throws {
        let featureCode = root + "/" + configuration.featureCodePath
        let libraryCode = root + "/" + configuration.libraryCodePath
        let mocks = root + "/" + configuration.mockPath
        if verbose {
            print("Input Paths:")
            print(featureCode)
            print(libraryCode)
            print("Output Path:")
            print(mocks)
        }
        var command = "mockolo -s \(featureCode) \(libraryCode) -d \(mocks)"
        if !configuration.mockolo.testableImports.isEmpty {
            if verbose {
                print("Adding Testable Imports")
                configuration.mockolo.testableImports.forEach { print($0) }
            }
            command.append(" ")
            command.append((["-i"] + configuration.mockolo.testableImports).joined(separator: " "))
        }
        if verbose {
            print("Running command \(command)")
        }
        try shellOut(to: command)
    }

}
