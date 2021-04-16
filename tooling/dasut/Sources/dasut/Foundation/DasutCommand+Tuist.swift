//
// ScoreFive
// Varun Santhanam
//

import Foundation

extension DasutCommand {

    func tuist(on root: String, bin: String, toolConfig: String, generationOptions: [String], workspace: String, verbose: Bool, action: () throws -> Void) throws {
        let options = generationOptions
            .map { "." + $0 }
            .reduce("") { prev, option in
                prev == "" ? option : prev + ", " + option
            }

        let settings = """
        import ProjectDescription

        let config = Config(
            generationOptions: [
                \(options)
            ]
        )
        """

        let dir = workspace + "/Tuist"
        let path = dir + "/Config.swift"
        _ = try? shell(script: "rm -rf \(dir)", at: root)
        try shell(script: "mkdir \(dir)", at: root, errorMessage: "Couldn't Generate Temporary Directory", verbose: verbose)
        try shell(script: "echo \"\(settings)\" > \(path)", at: root, errorMessage: "Couldn't Write Tuist Configuration", verbose: verbose)
        try shell(script: "\(bin) generate --path \(workspace)", at: root, errorMessage: "Couldn't Generate Project", verbose: verbose)
        _ = try? shell(script: "rm -rf \(dir)", at: root)
    }

}
