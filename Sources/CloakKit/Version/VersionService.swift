// Copyright © 2022 Andrew Lord.

/// Service to print the current project version.
public struct VersionService {
    private let printer: Printer

    /// Create the service.
    public init() {
        self.init(printer: Cloak.shared.printer)
    }

    init(printer: Printer) {
        self.printer = printer
    }

    /// Entry-point to run the service.
    public func run() {
        printer.printForced(Version.current)
    }
}
