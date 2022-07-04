// Copyright © 2022 Andrew Lord.

import Security

public struct SecretsService {
    public init() {}

    public func findSecrets(with keys: [SecretKey], service: String) -> [SecretKey: String] {
        var values: [SecretKey: String] = [:]
        let keychain = KeychainAccessor(service: service)
        for key in keys {
            values[key] = try? keychain.retrieve(for: key.raw)
        }
        return values
    }

    public func saveSecrets(_ secrets: [SecretKey: String], service: String) throws {
        let keychain = KeychainAccessor(service: service)
        for (key, value) in secrets {
            try handleFatalError {
                try keychain.save(value, for: key.raw)
            }
        }
    }
}
