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
        printer.printForced("\n\(key)")
    }

    /// Save an encryption key to the keychain.
    ///
    /// - parameter key: Encryption key
    /// - parameter service: Service for storing in keychain
    public func saveKey(key: String, service: String) {
        printer.printMessage("💾 Saving encryption key for \(service)")

        let keychain = KeychainAccessor(service: service)
        handleNonFatalError {
            try keychain.save(key, for: KeychainAccessor.encryptionKey)
            printer.printMessage("Encryption key saved!")
        }
    }

    /// Encrypt a value using encryption key from keychain.
    ///
    /// - parameter value: Value to encrypt
    /// - parameter service: Service for finding encryption key in keychain
    public func encrypt(value: String, service: String) throws {
        printer.printMessage("🔠 Encrypting \(value) for \(service)")

        let keychain = KeychainAccessor(service: service)
        guard let key = try? keychain.retrieve(for: KeychainAccessor.encryptionKey) else {
            printer.printError(.encryptionKeyNotFound)
            throw ExecutionError.failure
        }
        printer.printMessage("Encryption key read from keychain successfully")
        guard let encrypted = try? performEncrypt(value: value, using: key)?.base64String else {
            printer.printError(.encryptionFailed)
            throw ExecutionError.failure
        }
        printer.printForced("\n\(encrypted)")
    }

    private func performEncrypt(value: String, using key: String) throws -> Data? {
        let dataToProtect = value.data(using: .utf8)!
        let encryptionKey = SymmetricKey(data: Data(base64String: key)!)
        let nonceData = randomData(length: 12)
        let nonce = try AES.GCM.Nonce(data: nonceData)
        let sealedData = try AES.GCM.seal(dataToProtect, using: encryptionKey, nonce: nonce)
        return sealedData.combined
    }

    private func randomData(length: Int) -> Data {
        var data = Data(count: length)
        _ = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        return data
    }

    /// Decrypt a value using encryption key from keychain.
    ///
    /// - parameter value: Value to decrypt
    /// - parameter service: Service for finding encryption key in keychain
    public func decrypt(value: String, service: String) throws {
        printer.printMessage("🔠 Decrypting \(value) for \(service)")

        let keychain = KeychainAccessor(service: service)
        guard let key = try? keychain.retrieve(for: KeychainAccessor.encryptionKey) else {
            printer.printError(.encryptionKeyNotFound)
            throw ExecutionError.failure
        }
        printer.printMessage("Encryption key read from keychain successfully")
        guard let decrypted = try? performDecrypt(value: value, using: key) else {
            printer.printError(.encryptionFailed)
            throw ExecutionError.failure
        }
        printer.printForced("\n\(decrypted)")
    }

    private func performDecrypt(value: String, using key: String) throws -> String? {
        let encryptionKey = SymmetricKey(data: Data(base64String: key)!)
        guard let encryptedData = Data(base64String: value) else {
            return nil
        }
        let sealedData = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedData, using: encryptionKey)
        return String(data: decryptedData, encoding: .utf8)
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
