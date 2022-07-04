// Copyright © 2022 Andrew Lord.

import Foundation

enum EnvironmentKey: String {
    case encryptionKey = "CLOAK_ENCRYPTION_KEY"
    case service = "CLOAK_SERVICE"
}

func environment(for key: EnvironmentKey) -> String? {
    ProcessInfo.processInfo.environment[key.rawValue]
}
