// Copyright © 2022 Andrew Lord.

public struct SecretKey: Hashable {
    public let raw: String

    public init(raw: String) {
        self.raw = raw
    }
}
