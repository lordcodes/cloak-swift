// Copyright © 2022 Andrew Lord.

/// Configuration of the CloakKit framework.
public class Cloak {
    // TODO: Document
    public static let shared = Cloak()

    /// Control outputting of messages and errors, by default does nothing.
    ///
    /// There is a `ConsolePrinter` to print to console for CLI tools.
    public var printer: Printer = NoPrinter()

    // TODO: Document
    public lazy var config: CloakConfig = ConfigLoader.load()

    // TODO: Document
    public static func configure(block: (Cloak) -> Void) {
        block(shared)
    }

    let keychain: KeychainAccessor = KeychainAccessor()
}
