// Copyright © 2022 Andrew Lord.

/// Configure the CloakKit framework.
public class Configuration {
    /// Control outputting of messages and errors, by default does nothing.
    /// 
    /// There is a `ConsolePrinter` to print to console for CLI tools.
    public var printer: Printer = NoPrinter()
}
