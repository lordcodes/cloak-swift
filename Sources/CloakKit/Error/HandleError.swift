// Copyright © 2022 Andrew Lord.

func handleFatalError<ResultT>(block: () throws -> ResultT) throws -> ResultT {
    do {
        return try block()
    } catch let error as CloakError {
        printer.printError(error)
        throw ExitCode.failure
    } catch {
        printer.printError(.otherError(error.localizedDescription))
        throw ExitCode.failure
    }
}

func handleNonFatalError<ResultT>(block: () throws -> ResultT) -> ResultT? {
    do {
        return try block()
    } catch let error as CloakError {
        printer.printError(error)
        return nil
    } catch {
        printer.printError(.otherError(error.localizedDescription))
        return nil
    }
}
