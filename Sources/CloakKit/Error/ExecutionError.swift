// Copyright © 2022 Andrew Lord.

/// A fatal execution error, should end execution.
public enum ExecutionError: Error, Equatable {
    /// Indicates the entire operation should be failed.
    case failure
}
