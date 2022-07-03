// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct EncryptCommand {
    let programName: String
    let options: [String]

    func run() throws {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.configuration.printer = ConsolePrinter(quiet: isQuiet)
        guard let encryptValue = options.first else {
            print("Error: Missing value to encrypt\n")
            printHelp()
            return
        }
        guard let service = findService() else {
            print("Error: Missing service\n")
            printHelp()
            return
        }
        try EncryptionService().encrypt(value: encryptValue, service: service)
    }

    private func findService() -> String? {
        findServiceOption() ?? findServiceEnvironment()
    }

    private func findServiceOption() -> String? {
        guard let serviceIndex = options.firstIndex(where: { $0 == "-s" || $0 == "--service" }), options.count > serviceIndex + 1 else {
            return nil
        }
        return options[serviceIndex + 1]
    }

    private func findServiceEnvironment() -> String? {
        ProcessInfo.processInfo.environment["CLOAK_ENCRYPTION_KEY"]
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Save encryption key to keychain for use.

        USAGE: \(programName) savekey [--service SERVICE] [--quiet]

        OPTIONS:
          -s, --service           Service name for entries in Keychain.
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
