protocol CommandProcessor {
    func process(command: Command)
}

final class FakeCommandProcessor: CommandProcessor {
    func process(command: Command) {}
}
