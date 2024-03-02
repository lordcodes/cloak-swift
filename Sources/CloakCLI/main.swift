// Copyright © 2022 Andrew Lord.

import CloakKit
import Darwin
import Foundation

let programName = extractProgramName()

let command = MainCommand(arguments: Array(CommandLine.arguments.dropFirst()))
do {
    try command.run()
} catch ExitCode.success {
    exit(EXIT_SUCCESS)
} catch ExitCode.failure {
    exit(EXIT_FAILURE)
}

private func extractProgramName() -> String {
    guard let program = CommandLine.arguments.first else {
        exit(EXIT_SUCCESS)
    }
    return URL(fileURLWithPath: program).lastPathComponent
}
