import Testing
@testable import Core
@testable import ScenarioEngine
@testable import SimulatorIntegration

struct ActionExecutorTests {
    private let logger = Logger(component: "Test")
    private var processRunner: ProcessRunner!
    private var simctlClient: SimctlClient!
    private var actionExecutor: DefaultActionExecutor!

    init() {
        self.processRunner = ProcessRunner(logger: logger)
        self.simctlClient = SimctlClient(processRunner: processRunner, logger: logger)
        self.actionExecutor = DefaultActionExecutor(simctlClient: simctlClient, logger: logger)
    }

    @Test
    func testDelayAction() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await actionExecutor.execute(
            action: .delay(duration: 0.1),
            context: context
        )

        #expect(result != nil)
        #expect(result?.success == true)
        #expect(result?.duration >= 0.1)
    }

    @Test
    func testCustomCommandAction() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        // Test with a simple echo command
        let result = try? await actionExecutor.execute(
            action: .custom(command: "echo Hello"),
            context: context
        )

        #expect(result != nil)
        #expect(result?.success == true)
        #expect(result?.output?.contains("Hello") == true)
    }

    @Test
    func testActionWithCancelledContext() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger,
            cancellationToken: CancellationToken()
        )

        // Cancel the context
        context.cancellationToken.cancel()

        let result = try? await actionExecutor.execute(
            action: .delay(duration: 1.0),
            context: context
        )

        // Should fail due to cancellation
        #expect(result?.success == false)
    }

    @Test
    func testActionResultProperties() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await actionExecutor.execute(
            action: .delay(duration: 0.05),
            context: context
        )

        #expect(result?.action is ScenarioAction)
        #expect(result?.timestamp != nil)
        #expect(result?.duration >= 0)
    }

    @Test
    func testMultipleSequentialActions() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        // Execute multiple actions sequentially
        let result1 = try? await actionExecutor.execute(
            action: .delay(duration: 0.05),
            context: context
        )

        let result2 = try? await actionExecutor.execute(
            action: .delay(duration: 0.05),
            context: context
        )

        #expect(result1?.success == true)
        #expect(result2?.success == true)
    }
}
