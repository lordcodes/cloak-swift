// Copyright © 2022 Andrew Lord.

import Foundation

struct CloakConfig {
    let programName: String
    let encryptionKey: String?
    let service: String?
}

func loadConfig(programName: String) -> CloakConfig {
    let properties = configFileProperties()
    return CloakConfig(
        programName: programName,
        encryptionKey: properties.readProperty(for: .encryptionKey),
        service: properties.readProperty(for: .service)
    )
}

private func configFileProperties() -> [String: String] {
    let pathUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent(".cloak")
    guard let contents = try? String(contentsOfFile: pathUrl.path, encoding: .utf8) else {
        return [:]
    }
    let lines = contents.components(separatedBy: .newlines)
    var properties = [String: String]()
    for line in lines {
        let parts = line.split(separator: "=")
        if parts.count != 2 {
            continue
        }
        let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        properties[key] = value
    }
    return properties
}

private extension Dictionary where Key == String, Value == String {
    func readProperty(for key: EnvironmentKey) -> String? {
        self[key.rawValue] ?? environment(for: key)
    }
}
