// Copyright © 2022 Andrew Lord.

import Foundation
import Security

/// Service for resolving secrets and then generating a secrets file to use in-app.
public struct SecretsService {
    private let config: CloakConfig

    /// Create the service.
    public init() {
        self.init(config: Cloak.shared.config)
    }

    init(config: CloakConfig) {
        self.config = config
    }

    // TODO: Test
    /// Run the service.
    /// - throws: ExitCode when operation ends early due to success or failure.  
    public func run() throws {
        printer.printMessage("🤖 Generating secrets file")
        let secrets = readSecretsFromInputFile()
        let requiredSecretKeys = readRequiredSecretKeys()
        let environmentSecrets = findSecretsFromEnvironment(with: requiredSecretKeys)
        let mergedSecrets = secrets.merging(environmentSecrets) { _, environment in environment }
        let missingSecretKeys = requiredSecretKeys.filter { mergedSecrets[$0] == nil }

        if !missingSecretKeys.isEmpty {
            printer.printMessage("Not all required secrets were provided through input file and/or environment")
            printer.printError(.missingSecrets(secrets: missingSecretKeys))
        } else {
            printer.printMessage("All secrets found, generating secrets file")
            try generateSecretsFile(with: mergedSecrets)
        }
    }

    private func readSecretsFromInputFile() -> [SecretKey: String] {
        let secretsInputFilePath = ".cloak/.secrets"
        guard FileManager.default.fileExists(atPath: secretsInputFilePath) else {
            printer.printMessage("Secrets input file not found at \(secretsInputFilePath)")
            return [:]
        }
        printer.printMessage("Reading secrets and values from \(secretsInputFilePath)")
        guard let contents = try? String(contentsOfFile: secretsInputFilePath, encoding: .utf8) else {
            return [:]
        }
        let lines = contents.components(separatedBy: .newlines)
        var secrets = [SecretKey: String]()
        for line in lines {
            guard let equalsIndex = line.firstIndex(of: "=") else { continue }
            let key = String(line.prefix(upTo: equalsIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
            let value = line.suffix(from: line.index(after: equalsIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
            secrets[SecretKey(raw: key)] = value
        }
        printer.printMessage("Secrets and values read from \(secretsInputFilePath)")
        return secrets
    }

    private func readRequiredSecretKeys() -> [SecretKey] {
        let pathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".cloak")
            .appendingPathComponent("secret-keys")
        guard FileManager.default.fileExists(atPath: pathUrl.path) else {
            printer.printMessage("Required secrets file not found at .cloak/secret-keys so won't check for missing secrets")
            return []
        }
        guard let contents = try? String(contentsOfFile: pathUrl.path, encoding: .utf8) else {
            return []
        }
        let requiredKeys = contents.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map(SecretKey.init(raw:))
        printer.printMessage("Required secret keys read from .cloak/secret-keys")
        return requiredKeys
    }

    private func findSecretsFromEnvironment(with keys: [SecretKey]) -> [SecretKey: String] {
        var values: [SecretKey: String] = [:]
        for key in keys {
            values[key] = environment(for: key.raw)
        }
        printer.printMessage("Secrets retrieved from environment")
        return values
    }

    private func generateSecretsFile(with secrets: [SecretKey: String]) throws {
        var generatedFile = """
        // Generated using Cloak Swift — https://github.com/lordcodes/cloak-swift
        // DO NOT EDIT

        // swiftlint:disable all
        // swiftformat:disable all

        """
        let salt = generateSalt()
        let access = secretsAccessLevel()
        generatedFile += "\(access)enum \(config.secretsClassName) {\n"
        let sortedSecrets = secrets.sorted { $0.key.raw.lowercased() < $1.key.raw.lowercased() }
        for (key, value) in sortedSecrets {
            let obfuscatedValue = obfuscate(value: value, using: salt)
            generatedFile += "    \(access)static var \(key.raw.camelcased()): String {\n"
            generatedFile += "        let encoded: [UInt8] = \(obfuscatedValue)\n"
            generatedFile += "        return revealObfuscated(value: encoded)\n"
            generatedFile += "    }\n"
        }
        generatedFile += "\n"
        generatedFile += "    \(access)static let salt: [UInt8] = \(salt)\n\n"
        generatedFile += """
            private static func revealObfuscated(value: [UInt8]) -> String {
                let saltLength = salt.count
                var revealed = [UInt8]()
                for char in value.enumerated() {
                    revealed.append(char.element ^ salt[char.offset % saltLength])
                }
                return String(bytes: revealed, encoding: .utf8)!
            }
        """
        generatedFile += "\n}\n"
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let generatedPath = URL(string: config.secretsOutputFilePath, relativeTo: currentDirectory) else {
            return
        }
        do {
            try generatedFile.write(to: generatedPath, atomically: true, encoding: .utf8)
            printer.printMessage("Generated secrets file successfully")
        } catch {
            printer.printError(.writeSecretsToGeneratedFileFailed)
            throw ExitCode.failure
        }
    }

    private func secretsAccessLevel() -> String {
        guard let access = config.secretsAccessLevel else {
            return ""
        }
        return "\(access) "
    }

    private func obfuscate(value: String, using salt: [UInt8]) -> [UInt8] {
        let valueBytes = [UInt8](value.utf8)
        let saltLength = salt.count

        var obfuscated = [UInt8]()
        for char in valueBytes.enumerated() {
            obfuscated.append(char.element ^ salt[char.offset % saltLength])
        }
        return obfuscated
    }

    private func generateSalt() -> [UInt8] {
        let saltData = randomData(length: 64)
        return [UInt8](saltData)
    }

    private func randomData(length: Int) -> Data {
        var data = Data(count: length)
        _ = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        return data
    }
}

private extension String {
    func camelcased() -> String {
        guard !isEmpty else {
            return ""
        }
        return self
            .split(separator: "_")
            .map { String($0) }
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
}
