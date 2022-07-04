// Copyright © 2022 Andrew Lord.

import CloakKit

struct VersionCommand {
    let config: CloakConfig
    let options: [String]

    func run() {
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

    private func printUnexpectedOptionError(option: String) {
        print("Error: Unknown option '\(option)'\n")
        printHelp()
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Print version

        USAGE: \(config.programName) version

        OPTIONS:
          -h, --help              Show help information.
        
        """
        print(help)
    }
}
