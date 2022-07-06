// Copyright © 2022 Andrew Lord.

import Darwin
import Foundation
import CloakKit

struct MainCommand {
     let arguments: [String]

    public func run() throws {
        let (subcommand, options) = try extractSubcommand()
        switch subcommand {
        case "createkey":
            CreateKeyCommand(options: options).run()
        case "decrypt":
            try DecryptCommand(options: options).run()
        case "encrypt":
            try EncryptCommand(options: options).run()
        case "generate":
            try GenerateCommand(options: options).run()
        case "version":
            VersionCommand(options: options).run()
        case "-h", "--help":
            printHelp()
        default:
            try printUnexpectedArgumentError(argument: subcommand)
        }
    }

    private func extractSubcommand() throws -> (subcommand: String, options: [String]) {
        guard arguments.count > 0, let command = arguments.first else {
            printHelp()
            throw ExitCode.failure
        }
        return (subcommand: command, options: Array(arguments.dropFirst()))
    }

    private func printUnexpectedArgumentError(argument: String) throws {
        print("Error: Unknown argument '\(argument)'\n")
        printHelp()
        throw ExitCode.failure
    }

    private func printHelp() {
        let help = """
        USAGE: \(programName) <subcommand>

        OPTIONS:
          -h, --help              Show help information.

        SUBCOMMANDS:
          createkey               Create encryption key.
          decrypt                 Decrypt a value encrypted using cloak.
          encrypt                 Encrypt a value.
          generate                Read in secrets, obfuscate them and then generate a Swift file to access them within an app.
          version                 Print version.

        See '\(programName) <subcommand> --help' for detailed help.

        """
        print(help)
    }
}
