// Copyright © 2022 Andrew Lord.

func handleFatalError<ResultT>(block: () throws -> ResultT) throws -> ResultT {
    do {
        return try block()
    } catch let error as CloakError {
        Cloak.shared.printer.printError(error)
        throw ExitCode.failure
    } catch {
        Cloak.shared.printer.printError(.otherError(error.localizedDescription))
        throw ExitCode.failure
    }
}

func handleNonFatalError<ResultT>(block: () throws -> ResultT) -> ResultT? {
    do {
        return try block()
    } catch let error as CloakError {
        Cloak.shared.printer.printError(error)
        return nil
    } catch {
        Cloak.shared.printer.printError(.otherError(error.localizedDescription))
        return nil
    }
}
