// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct SecretsCommand {
    let config: CloakConfig
    let options: [String]

    func run() throws {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.configuration.printer = ConsolePrinter(quiet: isQuiet)
        guard let service = findService() else {
            print("Error: Missing service\n")
            printHelp()
            return
        }
        
        let secretKeys = readSecretKeys()
        let secretService = SecretsService()
        let secretValues = secretService.findSecrets(with: secretKeys, service: service)
        
        let missingSecrets = secretKeys.filter { secretValues[$0] == nil }
        var addSecretValues = [SecretKey: String]()
        for missingSecret in missingSecrets {
            var newValue: String?
            while newValue == nil {
                print("Please enter value for \(missingSecret):")
                newValue = readLine()
            }
            guard let secretValue = newValue else {
                print("Error: No value entered for \(missingSecret)")
                throw ExitCode.failure
            }
            addSecretValues[missingSecret] = secretValue
        }
        try secretService.saveSecrets(addSecretValues, service: service)

        let allSecrets = secretValues.merging(addSecretValues) { first, second in first }
        // TODO: Generate secrets Swift file
        print(allSecrets)
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

    private func readSecretKeys() -> [SecretKey] {
        let pathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".cloak-secrets")
        guard let contents = try? String(contentsOfFile: pathUrl.path, encoding: .utf8) else {
            return []
        }
        return contents.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map(SecretKey.init(raw:))
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Generate secrets Swift file for use in-app, missing secrets are requested and added to the keychain.

        USAGE: \(config.programName) secrets [--service SERVICE] [--quiet]

        OPTIONS:
          -s, --service           Service name for entries in Keychain (optional, can be provided through environment or config file).
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}
