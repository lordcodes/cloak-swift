// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct EncryptCommand {
    let options: [String]

    func run() throws {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.shared.printer = ConsolePrinter(quiet: isQuiet)
        guard let encryptValue = options.first else {
            print("Error: Missing value to encrypt\n")
            printHelp()
            return
        }
        try EncryptionService().encrypt(value: encryptValue)
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Save encryption key to keychain for use.

        USAGE: \(programName) savekey [--quiet]

        OPTIONS:
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
