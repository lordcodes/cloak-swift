// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct DecryptCommand {
    let options: [String]

    func run() throws {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.shared.printer = ConsolePrinter(quiet: isQuiet)
        guard let decryptValue = options.first else {
            print("Error: Missing value to decrypt\n")
            printHelp()
            return
        }
        try EncryptionService().decrypt(value: decryptValue)
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Decrypt an encrypted value.

        USAGE: \(programName) decrypt <encrypted> [--quiet]

        OPTIONS:
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
