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

protocol DasutCommand {
    func action() throws
}

extension DasutCommand {
    func execute(_ action: () throws -> Void) throws {
        do {
            try action()
        } catch {
            if let error = error as? DasutError {
                let message = error.message.withColor(.red)
                print(message, to: &io.stderr_stream)
                Darwin.exit(EXIT_FAILURE)
            } else {
                throw error
            }
        }
    }
}

extension ParsableCommand where Self: DasutCommand {

    func run() throws {
        try execute(action)
    }

}
