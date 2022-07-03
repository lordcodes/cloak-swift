// Copyright © 2022 Andrew Lord.

import CloakKit

struct VersionCommand {
    let programName: String
    let options: [String]

    func run() {
        if options.count > 1 {
            printMultipleOptionsError(options: options)
            return
        }
        switch options.first {
        case .none:
            performVersion()
        case .some("-h"), .some("--help"):
            printHelp()
        case let .some(other):
            printUnexpectedOptionError(option: other)
        }
    }

    private func performVersion() {
        Cloak.configuration.printer = ConsolePrinter(quiet: false)
        VersionService().run()
    }

    private func printMultipleOptionsError(options: [String]) {
        print("Error: Please provide single option from \(options)")
        printHelp()
    }

    private func printUnexpectedOptionError(option: String) {
        let message = """
        Error: Unknown option '\(option)'

        USAGE: \(programName) version

        OPTIONS:
          -h, --help              Show help information.

        """
        print(message)
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Print version

        USAGE: \(programName) version

        OPTIONS:
          -h, --help              Show help information.
        
        """
        print(help)
    }
}
