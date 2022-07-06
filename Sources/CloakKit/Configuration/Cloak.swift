// Copyright © 2022 Andrew Lord.

/// Configuration of the CloakKit framework.
public class Cloak {
    /// Shared Cloak instance.
    public static let shared = Cloak()

    /// Control outputting of messages and errors, by default does nothing.
    ///
    /// There is a `ConsolePrinter` to print to console for CLI tools.
    public var printer: Printer = NoPrinter()

    /// Config loaded from .cloak/config file or environment variables.
    public lazy var config: CloakConfig = ConfigLoader.load()
}
