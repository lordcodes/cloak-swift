// Copyright © 2022 Andrew Lord.

import CloakKit

struct CreateKeyCommand {
    let options: [String]

    func run() {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.shared.printer = ConsolePrinter(quiet: isQuiet)
        EncryptionService().createKey()
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
