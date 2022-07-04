// Copyright © 2022 Andrew Lord.

import Foundation

// TODO: Document
public struct CloakConfig {
    public let encryptionKey: String?
    public let service: String?
    public let secretsClassName: String
    public let secretsFilePath: String
    public let secretsAccessLevel: String?
}
