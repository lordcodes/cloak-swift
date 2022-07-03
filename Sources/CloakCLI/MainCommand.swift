// Copyright © 2022 Andrew Lord.

import Darwin
import Foundation

struct MainCommand {
     let arguments: [String]

    // TODO
    // encrypt -> provide raw secret, output encrypted secret
    // decrypt -> provide encrypted secret, output raw secret
    public func run() throws {
        let programName = try extractProgramName()
        let (subcommand, options) = try extractSubcommand(programName: programName)
        switch subcommand {
        case "createkey":
            CreateKeyCommand(programName: programName, options: options).run()
        case "savekey":
            SaveKeyCommand(programName: programName, options: options).run()
        case "version":
            VersionCommand(programName: programName, options: options).run()
        case "-h", "--help":
            printHelp(programName: programName)
        default:
            printUnexpectedArgumentError(programName: programName, argument: subcommand)
        }
    }

    private func extractProgramName() throws -> String {
        guard let program = arguments.first else {
            throw ExitCode.success
        }
        var programName = URL(fileURLWithPath: program).lastPathComponent
        if programName == "tuist-cloak" {
            programName = "tuist cloak"
        }
        return programName
    }

    private func extractSubcommand(programName: String) throws -> (subcommand: String, options: [String]) {
        let arguments = Array(arguments.dropFirst())
        guard arguments.count > 0, let command = arguments.first else {
            printHelp(programName: programName)
            throw ExitCode.failure
        }
        return (subcommand: command, options: Array(arguments.dropFirst()))
    }

    private func printUnexpectedArgumentError(programName: String, argument: String) {
        print("Error: Unknown argument '\(argument)'\n")
        printHelp(programName: programName)
    }

    private func printHelp(programName: String) {
        let help = """
        USAGE: \(programName) <subcommand>

        OPTIONS:
          -h, --help              Show help information.

        SUBCOMMANDS:
          createkey               Create encryption key.
          savekey                 Save encryption key to keychain for use.
          version                 Print version.

        See '\(programName) <subcommand> --help' for detailed help.

        """
        print(help)
    }
}
