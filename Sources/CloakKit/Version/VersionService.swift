// Copyright © 2022 Andrew Lord.

/// Service to print the current project version.
public struct VersionService {
    /// Create the service.
    public init() {}

    /// Entry-point to run the service.
    public func run() {
        printer.printForced(Version.current)
    }
}
