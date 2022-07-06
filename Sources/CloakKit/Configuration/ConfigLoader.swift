// Copyright © 2022 Andrew Lord.

import Foundation

enum ConfigLoader {
    // TODO: Test loading from config file, loading from environment, fallbacks and order these are taken
    static func load() -> CloakConfig {
        let properties = configFileProperties()
        return CloakConfig(
            encryptionKey: findEncryptionKey(),
            secretsClassName: properties.readProperty(for: .secretsClassName) ?? "CloakSecrets",
            secretsOutputFilePath: properties.readProperty(for: .secretsOutputFilePath) ?? "CloakSecrets.swift",
            secretsAccessLevel: properties.readProperty(for: .secretsAccessLevel)
        )
    }

    private static func configFileProperties() -> [String: String] {
        let pathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".cloak")
            .appendingPathComponent("config")
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

    private static func findEncryptionKey() -> String? {
        if let encryptionKey = environment(for: .encryptionKey) {
            return encryptionKey
        }
        let pathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".cloak")
            .appendingPathComponent(".secrets")
        guard let contents = try? String(contentsOfFile: pathUrl.path, encoding: .utf8) else {
            return nil
        }
        let lines = contents.components(separatedBy: .newlines)
        for line in lines {
            guard let equalsIndex = line.firstIndex(of: "=") else { continue }
            let key = String(line.prefix(upTo: equalsIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
            if key == EnvironmentKey.encryptionKey.rawValue {
                return line.suffix(from: line.index(after: equalsIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}

private extension Dictionary where Key == String, Value == String {
    func readProperty(for key: EnvironmentKey) -> String? {
        self[key.rawValue] ?? environment(for: key)
    }

    func readProperty(for rawKey: String) -> String? {
        self[rawKey] ?? environment(for: rawKey)
    }
}
