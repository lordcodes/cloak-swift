// Copyright © 2022 Andrew Lord.

import Foundation
import Security

typealias KeychainQuery = [String: Any]

// TODO: Test
class KeychainAccessor {
    static let encryptionKey = "EncryptionKey"

    init() {}

    private let lock = NSLock()

    func save(_ value: String, for account: String, service: String) throws {
        guard let valueData = value.data(using: .utf8) else {
            throw CloakError.keychainFailure(statusCode: errSecInvalidEncoding)
        }
        lock.lock()
        defer { lock.unlock() }

        deleteIfExists(account: account, service: service)

        var query = createQuery(service: service)
        query[KeychainConstants.account] = account
        query[KeychainConstants.valueData] = valueData
        let code = SecItemAdd(query as CFDictionary, nil)
        if code != noErr {
            throw CloakError.keychainFailure(statusCode: code)
        }
    }

    func retrieve(for account: String, service: String) throws -> String? {
        let data = try retriveData(for: account, service: service)
        guard let dataString = String(data: data, encoding: .utf8) else {
            throw CloakError.keychainFailure(statusCode: errSecInvalidEncoding)
        }
        return dataString
    }

    private func retriveData(for account: String, service: String) throws -> Data {
        lock.lock()
        defer { lock.unlock() }

        var query = createQuery(service: service)
        query[KeychainConstants.account] = account
        query[KeychainConstants.matchLimit] = kSecMatchLimitOne
        query[KeychainConstants.returnData] = kCFBooleanTrue

        var result: AnyObject?
        let code = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard code == noErr else {
            throw CloakError.keychainFailure(statusCode: code)
        }
        guard let data = result as? Data else {
            throw CloakError.keychainFailure(statusCode: errSecInvalidEncoding)
        }
        return data
    }

    private func createQuery(service: String) -> KeychainQuery {
        [
            KeychainConstants.klass: kSecClassGenericPassword,
            KeychainConstants.accessible: kSecAttrAccessibleAfterFirstUnlock,
            KeychainConstants.service: "cloak-\(service)",
        ]
    }

    private func deleteIfExists(account: String, service: String) {
        var query = createQuery(service: service)
        query[KeychainConstants.account] = account
        SecItemDelete(query as CFDictionary)
    }
}
