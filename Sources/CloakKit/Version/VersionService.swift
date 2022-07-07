// Copyright © 2022 Andrew Lord.

/// Service to print the current project version.
public struct VersionService {
    /// Create the service.
    public init() {}

    /// Run the service.
    public func run() {
        printer.printForced(Version.current)
    }
}
