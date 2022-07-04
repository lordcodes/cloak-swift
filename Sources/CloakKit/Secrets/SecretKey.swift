// Copyright © 2022 Andrew Lord.

// TODO: Document
public struct SecretKey: Hashable {
    public let raw: String

    public init(raw: String) {
        self.raw = raw
    }
}
