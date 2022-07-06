// Copyright © 2022 Andrew Lord.

import Foundation
import Security

/// Closure to read secret value, such as from standard input in a CLI tool.
public typealias SecretReader = () -> String?

/// Service for interacting with secrets such as saving to keychain and generating secrets file.
public struct SecretsService {
    private let interactiveMode: Bool
    private let service: String?
    private let readSecret: SecretReader
    private let keychain: KeychainAccessor
    private let printer: Printer
    private let config: CloakConfig

    /// Create the service.
    /// - parameter interactiveMode: Whether secret value can be captured interactively via `readSecret`.
    /// - parameter service: Service for finding encryption key in keychain.
    /// - parameter readSecret: Closure to capture the value for a secret.
    public init(interactiveMode: Bool, service: String?, readSecret: @escaping SecretReader) {
        self.init(
            interactiveMode: interactiveMode,
            service: service,
            readSecret: readSecret,
            keychain: Cloak.shared.keychain,
            printer: Cloak.shared.printer,
            config: Cloak.shared.config
        )
    }

    init(
        interactiveMode: Bool,
        service: String?,
        readSecret: @escaping SecretReader,
        keychain: KeychainAccessor,
        printer: Printer,
        config: CloakConfig
    ) {
        self.interactiveMode = interactiveMode
        self.service = service
        self.readSecret = readSecret
        self.keychain = keychain
        self.printer = printer
        self.config = config
    }

    // TODO: Test
    /// Save a secret to the keychain.
    /// - parameter key: Secret key name.
    /// - parameter value: Secret key value.
    /// - throws: ExitCode when operation failed. 
    public func saveSecret(key: SecretKey, value: String) throws {
        printer.printMessage("💾 Saving secret \(key.raw) to the keychain")
        try saveSecrets([key: value])
        printer.printMessage("Secret saved successfully")
    }

    // TODO: Test
    /// Save secrets that are listed in bulk within a file.
    /// - parameter file: File containing a list of secrets and their values.
    /// - throws: ExitCode when operation failed.
    public func saveBulkSecrets(filepath: String) throws {
        printer.printMessage("💾 Saving secrets from a file to the keychain")
        let secrets = readSecretsFromBulkFile(from: filepath)
        try saveSecrets(secrets)
        printer.printMessage("Secrets saved successfully")
    }

    private func readSecretsFromBulkFile(from filepath: String) -> [SecretKey: String] {
        printer.printMessage("Reading secrets and values from \(filepath)")
        guard let contents = try? String(contentsOfFile: filepath, encoding: .utf8) else {
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
        return secrets
    }

    // TODO: Test
    /// Delete a secret from the keychain.
    /// - parameter key: Secret key name.
    /// - throws: ExitCode when operation failed.
    public func deleteSecret(key: SecretKey) throws {
        printer.printMessage("🗑 Deleting secret \(key.raw) from the keychain")
        let service = try findService()
        try handleFatalError {
            try keychain.delete(account: key.raw, service: service)
        }
    }

    // TODO: Test
    /// Generate a Swift file to access secrets from the target application.
    /// - throws: ExitCode when operation failed.
    public func generateSecretsFile() throws {
        printer.printMessage("🤖 Generating secrets file")
        let secretKeys = readSecretKeys()
        printer.printMessage("Secret keys read from .cloak/secret-keys")
        let secretValues = try findSecrets(with: secretKeys)
        printer.printMessage("Secrets retrieved from keychain")
        let missingSecretKeys = secretKeys.filter { secretValues[$0] == nil }
        if interactiveMode, !missingSecretKeys.isEmpty {
            printer.printMessage("Interactive mode, requesting missing secrets and then generating secrets file")
            let missingSecretValues = try requestSecrets(keys: missingSecretKeys)
            let allSecrets = secretValues.merging(missingSecretValues) { first, second in first }
            try generateSecretsFile(with: allSecrets)
        } else if !missingSecretKeys.isEmpty {
            printer.printMessage("Non-interactive mode, printing out missing secrets")
            printer.printError(.missingSecrets(secrets: missingSecretKeys))
        } else {
            printer.printMessage("All secrets found, generating secrets file")
            try generateSecretsFile(with: secretValues)
        }
    }

    private func readSecretKeys() -> [SecretKey] {
        let pathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".cloak")
            .appendingPathComponent("secret-keys")
        guard let contents = try? String(contentsOfFile: pathUrl.path, encoding: .utf8) else {
            return []
        }
        return contents.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map(SecretKey.init(raw:))
    }

    private func findSecrets(with keys: [SecretKey]) throws -> [SecretKey: String] {
        var values: [SecretKey: String] = [:]
        for key in keys {
            values[key] = environment(for: key.raw)
            if values[key] == nil {
                let service = try findService()
                values[key] = try? keychain.retrieve(for: key.raw, service: service)
            }
        }
        return values
    }

    private func findService() throws -> String {
        guard let service = config.service ?? service else {
            printer.printError(.serviceMissing)
            throw ExitCode.failure
        }
        return service
    }

    private func requestSecrets(keys: [SecretKey]) throws -> [SecretKey: String] {
        var newValues = [SecretKey: String]()
        for secret in keys {
            var newValue: String?
            while newValue == nil || newValue?.isEmpty == true {
                printer.printForced("Please enter value for \(secret.raw):")
                newValue = readSecret()?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard let secretValue = newValue else {
                printer.printError(.secretKeyNoValueEntered(key: secret))
                throw ExitCode.failure
            }
            newValues[secret] = secretValue
        }
        try saveSecrets(newValues)
        return newValues
    }

    private func saveSecrets(_ secrets: [SecretKey: String]) throws {
        let service = try findService()
        for (key, value) in secrets {
            try handleFatalError {
                try keychain.save(value, for: key.raw, service: service)
            }
        }
    }

    private func generateSecretsFile(with secrets: [SecretKey: String]) throws {
        var generatedFile = """
        // Generated using Cloak Swift — https://github.com/lordcodes/cloak-swift
        // DO NOT EDIT

        // swiftlint:disable all
        // swiftformat:disable all

        """
        let access = secretsAccessLevel()
        generatedFile += "\(access)enum \(config.secretsClassName) {\n"
        let sortedSecrets = secrets.sorted { $0.key.raw.lowercased() < $1.key.raw.lowercased() }
        for (key, value) in sortedSecrets {
            generatedFile += "    \(access)static let \(key.raw.camelcased()) = \"\(value)\"\n"
        }
        generatedFile += "}\n"
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let generatedPath = URL(string: config.secretsFilePath, relativeTo: currentDirectory) else {
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
