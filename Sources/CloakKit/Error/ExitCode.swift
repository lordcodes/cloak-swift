// Copyright © 2022 Andrew Lord.

/// End execution with a status.
public enum ExitCode: Error {
    /// Indicates the entire operation should be marked as success.
    case success

    /// Indicates the entire operation should be marked as failure.
    case failure
}
