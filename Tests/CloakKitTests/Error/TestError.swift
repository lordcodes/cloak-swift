// Copyright © 2022 Andrew Lord.

import Foundation

enum TestError: Error {
    case failed
}

extension TestError: LocalizedError {
    var errorDescription: String? {
        description
    }
}

extension TestError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .failed:
            return "Failed"
        }
    }
}
