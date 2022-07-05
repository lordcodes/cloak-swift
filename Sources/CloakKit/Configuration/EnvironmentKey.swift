// Copyright © 2022 Andrew Lord.

import Foundation

// TODO: Document environment keys and config file keys in README
enum EnvironmentKey: String {
    case encryptionKey = "CLOAK_ENCRYPTION_KEY"
    case secretsClassName = "CLOAK_SECRETS_CLASS_NAME"
    case secretsFilePath = "CLOAK_SECRETS_FILEPATH"
    case secretsAccessLevel = "CLOAK_SECRETS_ACCESS_LEVEL"
    case service = "CLOAK_SERVICE"
}

func environment(for key: EnvironmentKey) -> String? {
    ProcessInfo.processInfo.environment[key.rawValue]
}

func environment(for rawKey: String) -> String? {
    ProcessInfo.processInfo.environment[rawKey]
}