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

        let symmetricKey = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let key = symmetricKey.base64String
        printer.printForced(key)
    }

    /// Save an encryption key to the keychain.
    ///
    /// - parameter key: Encryption key
    public func saveKey(key: String, service: String) {
        printer.printMessage("💾 Saving encryption key for \(service)")

        let keychain = KeychainAccessor(service: service)
        handleNonFatalError {
            try keychain.save(key, for: KeychainAccessor.encryptionKey)
            printer.printMessage("Encryption key saved!")
        }
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
