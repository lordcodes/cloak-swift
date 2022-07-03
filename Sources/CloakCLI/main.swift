// Copyright © 2022 Andrew Lord.

import Darwin

let command = MainCommand(arguments: CommandLine.arguments)
do {
    try command.run()
} catch ExitCode.success {
    exit(EXIT_SUCCESS)
} catch ExitCode.failure {
    exit(EXIT_FAILURE)
}
