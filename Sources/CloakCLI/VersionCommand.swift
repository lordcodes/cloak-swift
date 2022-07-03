// Copyright © 2022 Andrew Lord.

import CloakKit

struct VersionCommand {
    let programName: String
    let option: String?

    func run() {
        switch option {
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
