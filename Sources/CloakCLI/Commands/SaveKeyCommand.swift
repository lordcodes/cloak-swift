// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct SaveKeyCommand {
    let config: CloakConfig
    let options: [String]

    func run() {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.configuration.printer = ConsolePrinter(quiet: isQuiet)
        guard let key = options.first else {
            print("Error: Missing key\n")
            printHelp()
            return
        }
        guard let service = findService() else {
            print("Error: Missing service\n")
            printHelp()
            return
        }
        EncryptionService().saveKey(key: key, service: service)
    }

    private func findService() -> String? {
        findServiceOption() ?? config.service
    }

    private func findServiceOption() -> String? {
        guard let serviceIndex = options.firstIndex(where: { $0 == "-s" || $0 == "--service" }), options.count > serviceIndex + 1 else {
            return nil
        }
        return options[serviceIndex + 1]
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Save encryption key to keychain for use.

        USAGE: \(config.programName) savekey [--service SERVICE] [--quiet]

        OPTIONS:
          -s, --service           Service name for entries in Keychain (optional, can be provided through environment or config file).
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
