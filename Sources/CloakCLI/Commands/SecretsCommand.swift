// Copyright © 2022 Andrew Lord.

import CloakKit
import Foundation

struct SecretsCommand {
    let options: [String]

    func run() throws {
        if options.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printHelp()
            return
        }
        if programName.contains("tuist") {
            print("Unavailable via the Tuist plugin")
            return
        }
        let isQuiet = options.contains { $0 == "-q" || $0 == "--quiet" }
        Cloak.configure { cloak in
            cloak.printer = ConsolePrinter(quiet: isQuiet)
        }
        try SecretsService(service: findService(), readSecret: { readLine() }).run()
    }

    private func findService() -> String? {
        guard let serviceIndex = options.firstIndex(where: { $0 == "-s" || $0 == "--service" }), options.count > serviceIndex + 1 else {
            return nil
        }
        return options[serviceIndex + 1]
    }

    private func printHelp() {
        let help = """
        OVERVIEW: Generate secrets Swift file for use in-app, missing secrets are requested and added to the keychain.

        NOTE: Unavailable via the Tuist plugin.

        USAGE: \(programName) secrets [--service SERVICE] [--quiet]

        OPTIONS:
          -s, --service           Service name for entries in Keychain (optional, can be provided through environment or config file).
          -q, --quiet             Silence any output except errors.
          -h, --help              Show help information.

        """
        print(help)
    }
}

private let badChars = CharacterSet.alphanumerics.inverted

private extension String {
    func uppercasingFirst() -> String {
        prefix(1).uppercased() + dropFirst()
    }

    func lowercasingFirst() -> String {
        prefix(1).lowercased() + dropFirst()
    }

    func camelcased() -> String {
        guard !isEmpty else {
            return ""
        }
        let parts = self.components(separatedBy: badChars)
        let first = String(describing: parts.first!).lowercasingFirst()
        let rest = parts.dropFirst().map({ String($0).uppercasingFirst() })
        return ([first] + rest).joined(separator: "")
    }
}