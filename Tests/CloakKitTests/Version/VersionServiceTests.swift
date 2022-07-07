// Copyright © 2022 Andrew Lord.

import XCTest

@testable import CloakKit

class VersionServiceTests: XCTestCase {
    private let printer = FakePrinter()

    private lazy var service = VersionService()

    override func setUp() {
        super.setUp()

        Cloak.shared.printer = printer
    }

    override func tearDown() {
        Cloak.shared.printer = NoPrinter()

        super.tearDown()
    }

    func test_run() throws {
        service.run()

        XCTAssertEqual(printer.forcedMessagesPrinted.last, Version.current)
    }
}
