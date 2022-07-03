// Copyright © 2022 Andrew Lord.

import Foundation

/// Error type thrown by Cloak's throwing APIs.
public enum CloakError: Error, Equatable {
    // Other errors that weren't explicitly handled by the framework.
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
        case let .otherError(message):
            return "Other error, \(message)"
        }
    }
}
