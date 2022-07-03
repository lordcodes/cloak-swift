// Copyright © 2022 Andrew Lord.

import Darwin
import Foundation

struct MainCommand {
     let arguments: [String]

    public func run() throws {
        let programName = try extractProgramName()
        let (subcommand, option) = try extractSubcommand(programName: programName)
        switch subcommand {
        case "createkey":
            CreateKeyCommand(programName: programName, option: option).run()
        case "version":
            VersionCommand(programName: programName, option: option).run()
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

    private func extractSubcommand(programName: String) throws -> (subcommand: String, option: String?) {
        let arguments = Array(arguments.dropFirst())
        guard arguments.count > 0 else {
            printHelp(programName: programName)
            throw ExitCode.success
        }
        guard arguments.count <= 2, let command = arguments.first else {
            printHelp(programName: programName)
            throw ExitCode.failure
        }
        if arguments.count == 1 {
            return (subcommand: command, option: nil)
        }
        return (subcommand: command, option: arguments.last)
    }

    private func printUnexpectedArgumentError(programName: String, argument: String) {
        let message = """
        Error: Unknown argument '\(argument)'

        USAGE: \(programName) <subcommand>

        OPTIONS:
          -h, --help              Show help information.

        SUBCOMMANDS:
          install                 Install shared Git hooks
          uninstall               Uninstall shared Git hooks
          version                 Print version

        See '\(programName) <subcommand> --help' for detailed help.

        """
        print(message)
    }

    private func printHelp(programName: String) {
        let help = """
        USAGE: \(programName) <subcommand>

        OPTIONS:
          -h, --help              Show help information.

        SUBCOMMANDS:
          install                 Install shared Git hooks
          uninstall               Uninstall shared Git hooks
          version                 Print version

        See '\(programName) <subcommand> --help' for detailed help.

        """
        print(help)
    }
}
