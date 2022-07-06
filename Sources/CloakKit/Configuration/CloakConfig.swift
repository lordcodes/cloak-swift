// Copyright © 2022 Andrew Lord.

import Foundation

/// Config loaded from .cloak/config file or environment variables.
public struct CloakConfig {
    public let encryptionKey: String?
    public let secretsClassName: String
    public let secretsOutputFilePath: String
    public let secretsAccessLevel: String?
}
