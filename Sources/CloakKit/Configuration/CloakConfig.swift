// Copyright © 2022 Andrew Lord.

import Foundation

/// Config loaded from .cloak/config file or environment variables.
public struct CloakConfig {
    public let encryptionKey: String?
    public let service: String?
    public let secretsClassName: String
    public let secretsFilePath: String
    public let secretsAccessLevel: String?
}
