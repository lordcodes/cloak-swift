// Copyright © 2022 Andrew Lord.

import Foundation
import Security

// TODO: Document
public typealias SecretReader = () -> String?

// TODO: Document
public struct SecretsService {
    private let service: String?
    private let readSecret: SecretReader
    private let keychain: KeychainAccessor
    private let printer: Printer
    private let config: CloakConfig

    // TODO: Document
    public init(service: String?, readSecret: @escaping SecretReader) {
        self.init(
            service: service,
            readSecret: readSecret,
            keychain: Cloak.shared.keychain,
            printer: Cloak.shared.printer,
            config: Cloak.shared.config
        )
    }

    init(service: String?, readSecret: @escaping SecretReader, keychain: KeychainAccessor, printer: Printer, config: CloakConfig) {
        self.service = service
        self.readSecret = readSecret
        self.keychain = keychain
        self.printer = printer
        self.config = config
    }

    // TODO: Test
    // TODO: Document
    public func run() throws {
        let secretKeys = readSecretKeys()
        let secretValues = try findSecrets(with: secretKeys)
        let allSecrets = try fillMissingSecrets(secretKeys: secretKeys, secretValues: secretValues)
        try generateSecretsFile(with: allSecrets)
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

    private func fillMissingSecrets(
        secretKeys: [SecretKey],
        secretValues: [SecretKey: String]
    ) throws -> [SecretKey: String] {
        let missingSecrets = secretKeys.filter { secretValues[$0] == nil }
        var addSecretValues = [SecretKey: String]()
        for missingSecret in missingSecrets {
            var newValue: String?
            while newValue == nil || newValue?.isEmpty == true {
                printer.printForced("Please enter value for \(missingSecret.raw):")
                newValue = readSecret()?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard let secretValue = newValue else {
                printer.printError(.secretKeyNoValueEntered(key: missingSecret))
                throw ExitCode.failure
            }
            addSecretValues[missingSecret] = secretValue
        }
        try saveSecrets(addSecretValues)
        return secretValues.merging(addSecretValues) { first, second in first }
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
        for (key, value) in secrets {
            generatedFile += "    \(access)static let \(key.raw.camelcased()) = \"\(value)\"\n"
        }
        generatedFile += "}\n"
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let generatedPath = URL(string: config.secretsFilePath, relativeTo: currentDirectory) else {
            return
        }
        do {
            try generatedFile.write(to: generatedPath, atomically: true, encoding: .utf8)
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
