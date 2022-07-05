// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct SaveSecretCommand {
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
        try secretsService.saveSecret(key: SecretKey(raw: try parseKey()), value: try parseValue())
    }

    private func parseKey() throws -> String {
        guard options.count >= 1, let key = options.first else {
            print("Error: Missing secret key, provide as first argument\n")
            printHelp()
            throw ExitCode.failure
        }
        return key
    }

    private func parseValue() throws -> String {
        guard options.count >= 2 else {
            print("Error: Missing secret value, provide as second argument\n")
            printHelp()
            throw ExitCode.failure
        }
        return options[1]
    }

    private func findService() -> String? {
        guard let serviceIndex = options.firstIndex(where: { $0 == "-s" || $0 == "--service" }), options.count > serviceIndex + 1 else {
            return nil
        }
        return options[serviceIndex + 1]
    }

    private func printMissingOptions() {
        print("Error: Missing secret key or value options.")
        printHelp()
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Save a secret to the keychain.

        USAGE: \(programName) secret [KEY] [VALUE] [--service SERVICE] [--quiet]

        OPTIONS:
          -s, --service           Service name for entries in Keychain (optional, can be provided through environment or config file).
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
