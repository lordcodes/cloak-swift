// Copyright © 2022 Andrew Lord.

import Foundation

/// Configuration of the CloakKit framework.
public class Cloak {
    // TODO: Document
    public static let shared = Cloak()

    /// Control outputting of messages and errors, by default does nothing.
    ///
    /// There is a `ConsolePrinter` to print to console for CLI tools.
    public var printer: Printer = NoPrinter()

    // TODO: Document
    public lazy var config: CloakConfig = loadConfig()

    private func loadConfig() -> CloakConfig {
        let properties = configFileProperties()
        return CloakConfig(
            encryptionKey: properties.readProperty(for: .encryptionKey),
            service: properties.readProperty(for: .service),
            secretsClassName: properties.readProperty(for: .secretsClassName) ?? "CloakSecrets",
            secretsFilePath: properties.readProperty(for: .secretsFilePath) ?? "CloakSecrets.swift"
        )
    }

    private func configFileProperties() -> [String: String] {
        let pathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".cloak")
        guard let contents = try? String(contentsOfFile: pathUrl.path, encoding: .utf8) else {
            return [:]
        }
        let lines = contents.components(separatedBy: .newlines)
        var properties = [String: String]()
        for line in lines {
            let parts = line.split(separator: "=")
            if parts.count != 2 {
                continue
            }
            let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            properties[key] = value
        }
        return properties
    }

    // TODO: Document
    public static func configure(block: (Cloak) -> Void) {
        block(shared)
    }

    let keychain: KeychainAccessor = KeychainAccessor()
}

private extension Dictionary where Key == String, Value == String {
    func readProperty(for key: EnvironmentKey) -> String? {
        self[key.rawValue] ?? environment(for: key)
    }

    func readProperty(for rawKey: String) -> String? {
        self[rawKey] ?? environment(for: rawKey)
    }
}
