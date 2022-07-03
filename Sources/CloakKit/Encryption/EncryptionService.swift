// Copyright © 2022 Andrew Lord.

import CryptoKit
import Foundation

/// Service for creating encryption keys and encrypting secrets.
public struct EncryptionService {
    /// Create the service.
    public init() {}

    /// Create a new encryption key and print it.
    public func createKey() {
        printer.printMessage("🔑 Creating encryption key")

        let key = createEncryptionKey()
        printer.printForced(key)
    }

    private func createEncryptionKey() -> String {
        let key = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        return key.base64String
    }
}

private extension Data {
    init?(base64String string: String) {
        self.init(base64Encoded: string, options: .ignoreUnknownCharacters)
    }

    var base64String: String {
        base64EncodedString()
    }
}
