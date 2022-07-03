// Copyright © 2022 Andrew Lord.

import Security

struct KeychainConstants {
    static var accessible: String = toString(kSecAttrAccessible)
    static var accessibleAfterFirstUnlock: String = toString(kSecAttrAccessibleAfterFirstUnlock)
    static var account: String = toString(kSecAttrAccount)
    static var klass: String = toString(kSecClass)
    static var matchLimit: String = toString(kSecMatchLimit)
    static var returnData: String = toString(kSecReturnData)
    static var service: String = toString(kSecAttrService)
    static var synchronizable: String = toString(kSecAttrSynchronizable)
    static var valueData: String = toString(kSecValueData)

    private static func toString(_ value: CFString) -> String {
        value as String
    }
}
