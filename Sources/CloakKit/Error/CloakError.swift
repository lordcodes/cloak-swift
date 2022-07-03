// Copyright © 2022 Andrew Lord.

import Foundation

/// Error type thrown by Cloak's throwing APIs.
public enum CloakError: Error, Equatable {
    /// Encryption failed.
    case encryptionFailed

    /// Encryption key not found.
    case encryptionKeyNotFound

    /// Keychain operation failed.
    /// - parameter statusCode: Status code of the keychain error.
    case keychainFailure(statusCode: OSStatus)

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
        case let .keychainFailure(statusCode):
            return "Keychain error, status code \(statusCode)"
        case let .otherError(message):
            return "Other error, \(message)"
        }
    }
}
