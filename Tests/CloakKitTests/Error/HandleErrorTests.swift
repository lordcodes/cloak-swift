// Copyright © 2022 Andrew Lord.

import XCTest

@testable import CloakKit

class HandleErrorTests: XCTestCase {
    private let printer = FakePrinter()

    override func setUpWithError() throws {
        Cloak.shared.printer = printer
    }

    override func tearDownWithError() throws {
        Cloak.shared.printer = NoPrinter()
    }

    func test_handleFatalError_noError() throws {
        let actual = try handleFatalError { "Success" }

        XCTAssertEqual(actual, "Success")
        XCTAssertNil(printer.errorsPrinted.last)
    }

    func test_handleFatalError_SwiftHooksError() throws {
        XCTAssertThrowsError(
            try handleFatalError { throw CloakError.encryptionFailed }
        ) { error in
            XCTAssertEqual(error as! ExitCode, ExitCode.failure)
        }
        let printedError = printer.errorsPrinted.last
        XCTAssertNotNil(printedError)
        XCTAssertEqual(printedError, CloakError.encryptionFailed)
    }

    func test_handleFatalError_otherError() throws {
        XCTAssertThrowsError(
            try handleFatalError { throw TestError.failed }
        ) { error in
            XCTAssertEqual(error as! ExitCode, ExitCode.failure)
        }
        let printedError = printer.errorsPrinted.last
        XCTAssertNotNil(printedError)
        XCTAssertEqual(printedError, CloakError.otherError("Failed"))
    }

    func test_handleNonFatalError_noError() throws {
        handleNonFatalError { let _ = 6 }

        XCTAssertNil(printer.errorsPrinted.last)
    }

    func test_handleNonFatalError_SwiftHooksError() throws {
        handleNonFatalError { throw CloakError.encryptionKeyNotFound }

        let printedError = printer.errorsPrinted.last
        XCTAssertNotNil(printedError)
        XCTAssertEqual(printedError, CloakError.encryptionKeyNotFound)
    }

    func test_handleNonFatalError_otherError() throws {
        handleNonFatalError { throw TestError.failed }

        let printedError = printer.errorsPrinted.last
        XCTAssertNotNil(printedError)
        XCTAssertEqual(printedError, CloakError.otherError("Failed"))
    }
}
