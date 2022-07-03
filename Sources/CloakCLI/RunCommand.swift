// Copyright © 2022 Andrew Lord.

import CloakKit
import Darwin

func runCommand(runCommand: () throws -> Void) {
    do {
        try runCommand()
    } catch ExecutionError.failure {
        exit(EXIT_FAILURE)
    } catch {
        print(error)
        exit(EXIT_FAILURE)
    }
}
