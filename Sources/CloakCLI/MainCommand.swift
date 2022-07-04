// Copyright © 2022 Andrew Lord.

import Darwin
import Foundation
import CloakKit

struct MainCommand {
     let arguments: [String]

    public func run() throws {
        let programName = try extractProgramName()
        let (subcommand, options) = try extractSubcommand(programName: programName)
        let config = loadConfig(programName: programName)
        switch subcommand {
        case "createkey":
            CreateKeyCommand(config: config, options: options).run()
        case "decrypt":
            try DecryptCommand(config: config, options: options).run()
        case "encrypt":
            try EncryptCommand(config: config, options: options).run()
        case "savekey":
            SaveKeyCommand(config: config, options: options).run()
        case "version":
            VersionCommand(config: config, options: options).run()
        case "-h", "--help":
            printHelp(programName: programName)
        default:
            try printUnexpectedArgumentError(programName: programName, argument: subcommand)
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

    private func printUnexpectedArgumentError(programName: String, argument: String) throws {
        print("Error: Unknown argument '\(argument)'\n")
        printHelp(programName: programName)
        throw ExitCode.failure
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
