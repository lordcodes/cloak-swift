// Copyright © 2022 Andrew Lord.

import Foundation

enum EnvironmentKey: String {
    case encryptionKey = "CLOAK_ENCRYPTION_KEY"
    case secretsClassName = "CLOAK_SECRETS_CLASS_NAME"
    case secretsOutputFilePath = "CLOAK_SECRETS_OUTPUT_FILEPATH"
    case secretsAccessLevel = "CLOAK_SECRETS_ACCESS_LEVEL"
}

func environment(for key: EnvironmentKey) -> String? {
    ProcessInfo.processInfo.environment[key.rawValue]
}

func environment(for rawKey: String) -> String? {
    ProcessInfo.processInfo.environment[rawKey]
}
