// Copyright © 2022 Andrew Lord.

import CloakKit

struct CreateKeyCommand {
    let programName: String
    let options: [String]

    func run() {
        if options.count > 1 {
            printMultipleOptionsError(options: options)
            return
        }
        switch options.first {
        case .none:
            performCreateKey(isQuiet: false)
        case .some("-q"), .some("--quiet"):
            performCreateKey(isQuiet: true)
        case .some("-h"), .some("--help"):
            printHelp()
        case let .some(other):
            printUnexpectedOptionError(option: other)
        }
    }

    private func performCreateKey(isQuiet: Bool) {
        Cloak.configuration.printer = ConsolePrinter(quiet: isQuiet)
        EncryptionService().createKey()
    }

    private func printMultipleOptionsError(options: [String]) {
        print("Error: Please provide single option from \(options)")
        printHelp()
    }

    private func printUnexpectedOptionError(option: String) {
        print("Error: Unknown option '\(option)'\n")
        printHelp()
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Create encryption key.

        USAGE: \(programName) createkey [--quiet]

        OPTIONS:
          -q, --quiet             Silence any output except errors
          -h, --help              Show help information.

        """
        print(help)
    }
}
