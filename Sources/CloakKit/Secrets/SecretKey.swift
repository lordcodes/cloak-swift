// Copyright © 2022 Andrew Lord.

/// Type-safe wrapper for secret keys to avoid confusing the key name and value whe using Cloak APIs.
public struct SecretKey: Hashable {
    /// Raw name of secret key.
    public let raw: String

    /// Create a secret key instance.
    /// - parameter raw: Raw name of secret key.
    public init(raw: String) {
        self.raw = raw
    }
}
