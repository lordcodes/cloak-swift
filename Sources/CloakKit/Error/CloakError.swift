// Copyright © 2022 Andrew Lord.

import Foundation

/// Error type thrown by Cloak's throwing APIs.
public enum CloakError: Error, Equatable {
    /// Encryption failed.
    case encryptionFailed

    /// Encryption key not found.
    case encryptionKeyNotFound

    /// Failed to generate secrets file due to missing secrets.
    /// - parameter secrets: Secret keys that have no value saved.
    case missingSecrets(secrets: [SecretKey])

    /// Failed to write secrets to generated file.
    case writeSecretsToGeneratedFileFailed

    /// Other errors that weren't explicitly handled by the framework.
    case otherError(String)
}

extension CloakError: LocalizedError {
    public var errorDescription: String? {
        description
    }
}

extension CloakError: CustomStringConvertible {
    public var description: String {
        """
        Cloak encountered an error.
        Reason: \(reason)
        """
    }

    private var reason: String {
        switch self {
        case .encryptionFailed:
            return  "Encryption failed"
        case .encryptionKeyNotFound:
            return "Encryption key not found in keychain"
        case let .missingSecrets(secrets):
            let secretsMessage = secrets.map { $0.raw }.joined(separator: ", ")
            return "Failed to generate secrets file due to missing secrets.\n\n\(secretsMessage)"
        case .writeSecretsToGeneratedFileFailed:
            return "Failed to write secrets to generated file"
        case let .otherError(message):
            return "Other error, \(message)"
        }
    }
}
