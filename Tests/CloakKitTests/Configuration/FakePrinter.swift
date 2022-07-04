// Copyright © 2022 Andrew Lord.

@testable import CloakKit

class FakePrinter: Printer {
    var messagesPrinted = [String]()
    var forcedMessagesPrinted = [String]()
    var errorsPrinted = [CloakError]()

    func printMessage(_ message: @autoclosure () -> String) {
        messagesPrinted.append(message())
    }

    func printForced(_ message: @autoclosure () -> String) {
        forcedMessagesPrinted.append(message())
    }

    func printError(_ error: CloakError) {
        errorsPrinted.append(error)
    }
}
