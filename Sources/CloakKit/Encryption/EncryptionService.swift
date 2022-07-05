// Copyright © 2022 Andrew Lord.

import CryptoKit
import Foundation

/// Service for creating encryption keys and encrypting secrets.
public struct EncryptionService {
    private let service: String?
    private let keychain: KeychainAccessor
    private let printer: Printer
    private let config: CloakConfig

    /// Create the service.
    /// - parameter service: Service for finding encryption key in keychain
    public init(service: String?) {
        self.init(
            service: service,
            keychain: Cloak.shared.keychain,
            printer: Cloak.shared.printer,
            config: Cloak.shared.config
        )
    }

    init(service: String?, keychain: KeychainAccessor, printer: Printer, config: CloakConfig) {
        self.service = service
        self.keychain = keychain
        self.printer = printer
        self.config = config
    }

    // TODO: Test
    /// Create a new encryption key and print it.
    public func createKey() {
        printer.printMessage("🔑 Creating encryption key")

        let symmetricKey = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let key = symmetricKey.base64String
        printer.printForced("\n\(key)")
    }

    // TODO: Test
    /// Save an encryption key to the keychain.
    /// - parameter key: Encryption key
    /// - throws: ExitCode when operation failed.
    public func saveKey(key: String) throws {
        printer.printMessage("💾 Saving encryption key")

        let service = try findService()
        handleNonFatalError {
            try keychain.save(key, for: KeychainAccessor.encryptionKey, service: service)
            printer.printMessage("Encryption key saved!")
        }
    }

    private func findService() throws -> String {
        guard let service = config.service ?? service else {
            printer.printError(.serviceMissing)
            throw ExitCode.failure
        }
        return service
    }

    // TODO: Test
    /// Encrypt a value using encryption key from keychain.
    /// - parameter value: Value to encrypt
    /// - throws: ExitCode when operation failed.
    public func encrypt(value: String) throws {
        printer.printMessage("🔠 Encrypting \(value)")

        guard let key = try findEncryptionKey() else {
            printer.printError(.encryptionKeyNotFound)
            throw ExitCode.failure
        }
        printer.printMessage("Encryption key read from keychain successfully")
        guard let encrypted = try? performEncrypt(value: value, using: key)?.base64String else {
            printer.printError(.encryptionFailed)
            throw ExitCode.failure
        }
        printer.printForced("\n\(encrypted)")
    }

    private func findEncryptionKey() throws -> String? {
        if let key = config.encryptionKey {
            return key
        }
        return try encryptionKeyFromKeychain()
    }

    private func encryptionKeyFromKeychain() throws -> String? {
        let service = try findService()
        return try? keychain.retrieve(for: KeychainAccessor.encryptionKey, service: service)
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

    // TODO: Test
    /// Decrypt a value using encryption key from keychain.
    /// - parameter value: Value to decrypt
    /// - throws: ExitCode when operation failed. 
    public func decrypt(value: String) throws {
        printer.printMessage("🔠 Decrypting \(value)")

        guard let key = try findEncryptionKey() else {
            printer.printError(.encryptionKeyNotFound)
            throw ExitCode.failure
        }
        printer.printMessage("Encryption key read from keychain successfully")
        guard let decrypted = try? performDecrypt(value: value, using: key) else {
            printer.printError(.encryptionFailed)
            throw ExitCode.failure
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
