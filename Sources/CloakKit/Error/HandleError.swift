// Copyright © 2022 Andrew Lord.

func handleFatalError<ResultT>(block: () throws -> ResultT) throws -> ResultT {
    do {
        return try block()
    } catch let error as CloakError {
        printer.printError(error)
        throw ExecutionError.failure
    } catch {
        printer.printError(.otherError(error.localizedDescription))
        throw ExecutionError.failure
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
