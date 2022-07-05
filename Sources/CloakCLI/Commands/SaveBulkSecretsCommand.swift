// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct SaveBulkSecretsCommand {
    let options: [String]

    func run() throws {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.configure { cloak in
            cloak.printer = ConsolePrinter(quiet: isQuiet)
        }
        let secretsService = SecretsService(
            interactiveMode: !programName.contains("tuist"),
            service: findService(),
            readSecret: { readLine() }
        )
        try secretsService.saveBulkSecrets(filepath: try parseFile())
    }

    private func parseFile() throws -> String {
        guard options.count >= 1, let path = options.first else {
            print("Error: Missing bulk secrets file, provide as first argument\n")
            printHelp()
            throw ExitCode.failure
        }
        return path
    }

    private func findService() -> String? {
        guard let serviceIndex = options.firstIndex(where: { $0 == "-s" || $0 == "--service" }), options.count > serviceIndex + 1 else {
            return nil
        }
        return options[serviceIndex + 1]
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Save bulk secrets from a file to the keychain.

        USAGE: \(programName) secrets [FILEPATH] [--service SERVICE] [--quiet]

        OPTIONS:
          -s, --service           Service name for entries in Keychain (optional, can be provided through environment or config file).
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
