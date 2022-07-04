// Copyright © 2022 Andrew Lord.

import XCTest

@testable import CloakKit

class VersionServiceTests: XCTestCase {
    private let printer = FakePrinter()

    private lazy var service = VersionService(printer: printer)

    func test_run() throws {
        service.run()

        XCTAssertEqual(printer.forcedMessagesPrinted.last, Version.current)
    }
}
