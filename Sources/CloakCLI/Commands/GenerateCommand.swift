// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct GenerateCommand {
    let options: [String]

    func run() throws {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.shared.printer = ConsolePrinter(quiet: isQuiet)
        try SecretsService().run()
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Generate secrets Swift file for use in-app, with secrets being read from the secrets input file.
        If a .cloak/secret-keys file is provided, then any missing keys from the input file will be printed out.

        USAGE: \(programName) generate [--quiet]

        OPTIONS:
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
