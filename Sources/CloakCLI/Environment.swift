// Copyright © 2022 Andrew Lord.

import Foundation

enum Environment {
    static var service: String? {
        environmentVariable("CLOAK_SERVICE")
    }

    static var encryptionKey: String? {
        environmentVariable("CLOAK_ENCRYPTION_KEY")
    }

    private static func environmentVariable(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
}
