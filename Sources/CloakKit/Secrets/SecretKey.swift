// Copyright © 2022 Andrew Lord.

/// Type-safe wrapper for secret keys to avoid confusing the key name and value whe using Cloak APIs.
public struct SecretKey: Hashable {
    public let raw: String

    public init(raw: String) {
        self.raw = raw
    }
}
