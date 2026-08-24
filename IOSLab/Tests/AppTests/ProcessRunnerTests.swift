import Testing
@testable import Core
@testable import SimulatorIntegration

struct ProcessRunnerTests {
    private let logger = Logger(component: "Test")
    private var processRunner: ProcessRunner!

    init() {
        self.processRunner = ProcessRunner(logger: logger)
    }

    @Test
    func testEchoCommand() async {
        do {
            let result = try await processRunner.runShell(command: "echo Hello, World!")
            #expect(result.output.contains("Hello, World!"))
            #expect(result.exitCode == 0)
        } catch {
            Issue.record("Failed to run echo command: \(error)")
        }
    }

    @Test
    func testCurrentDirectory() async {
        do {
            let result = try await processRunner.runShell(command: "pwd")
            #expect(!result.output.isEmpty)
            #expect(result.exitCode == 0)
        } catch {
            Issue.record("Failed to get current directory: \(error)")
        }
    }
}
