// Copyright © 2022 Andrew Lord.

import Foundation
import Security

public typealias SecretReader = () -> String?

public struct SecretsService {
    private let service: String?
    private let readSecret: SecretReader
    private let keychain: KeychainAccessor
    private let printer: Printer
    private let config: CloakConfig

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

    public func run() throws {
        let secretKeys = readSecretKeys()
        let secretValues = try findSecrets(with: secretKeys)
        let allSecrets = try fillMissingSecrets(secretKeys: secretKeys, secretValues: secretValues)

        var generatedFile = "// Generated using Cloak Swift — https://github.com/lordcodes/cloak-swift\n"
        generatedFile += "// DO NOT EDIT\n"
        generatedFile += "\n"
        generatedFile += "// swiftlint:disable all\n"
        generatedFile += "// swiftformat:disable all\n"
        generatedFile += "\n"
        generatedFile += "enum \(config.secretsClassName) {\n"
        for (key, value) in allSecrets {
            generatedFile += "    static let \(key.raw.camelcased()) = \"\(value)\"\n"
        }
        generatedFile += "}\n"
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        guard let generatedPath = URL(string: config.secretsFilePath, relativeTo: currentDirectory) else {
            return
        }
        do {
            try generatedFile.write(to: generatedPath, atomically: true, encoding: .utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
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

    private func findSecrets(with keys: [SecretKey]) throws -> [SecretKey: String] {
        var values: [SecretKey: String] = [:]
        for key in keys {
            values[key] = environment(for: key.raw)
            if values[key] == nil {
                values[key] = try? keychain.retrieve(for: key.raw, service: try findService())
            }
        }
        return values
    }

    private func findService() throws -> String {
        guard let service = config.service ?? service else {
            throw CloakError.serviceMissing
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
        for (key, value) in secrets {
            try handleFatalError {
                try keychain.save(value, for: key.raw, service: try findService())
            }
        }
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
