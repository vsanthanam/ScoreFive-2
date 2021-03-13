//
//  File.swift
//
//
//  Created by Varun Santhanam on 3/13/21.
//

import ArgumentParser
import Foundation

struct GenerateCICommand: ParsableCommand {

    // MARK: - Initializers

    init() {}

    // MARK: - ParsableCommand

    static let configuration = CommandConfiguration(commandName: "ci",
                                                    abstract: "generate ci script")

    @Option(name: .shortAndLong, help: "Location of the score five repo")
    var root: String = FileManager.default.currentDirectoryPath

    func run() throws {
        let configuration = try fetchConfiguration(on: root)
        let device = configuration.testConfig.device
        let os = configuration.testConfig.os
        print("./sftool analytics wipe && ./sftool gen mocks && ./sftool gen deps && tuist test ScoreFive --device \"\(device)\" --os \(os)")
    }
}
