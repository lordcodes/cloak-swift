// Copyright © 2022 Andrew Lord.

/// Globals for the CloakKit framework.
public enum Cloak {
    /// Access configuration for the framework.
    public static let configuration: Configuration = Configuration()
}

var printer: Printer {
    Cloak.configuration.printer
}
