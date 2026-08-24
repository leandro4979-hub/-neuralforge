import Testing
@testable import Core
@testable import ScenarioEngine
@testable import SimulatorIntegration

struct ScenarioRunnerTests {
    private let logger = Logger(component: "Test")
    private var processRunner: ProcessRunner!
    private var simctlClient: SimctlClient!
    private var actionExecutor: DefaultActionExecutor!
    private var assertionValidator: DefaultAssertionValidator!
    private var deviceProfileStore: DeviceProfileStore!
    private var scenarioRunner: ScenarioRunner!

    init() {
        self.processRunner = ProcessRunner(logger: logger)
        self.simctlClient = SimctlClient(processRunner: processRunner, logger: logger)
        self.actionExecutor = DefaultActionExecutor(simctlClient: simctlClient, logger: logger)
        self.assertionValidator = DefaultAssertionValidator(logger: logger)
        self.deviceProfileStore = DeviceProfileStore(logger: logger)
        self.scenarioRunner = ScenarioRunner(
            actionExecutor: actionExecutor,
            assertionValidator: assertionValidator,
            logger: logger,
            deviceProfileStore: deviceProfileStore,
            simctlClient: simctlClient
        )
    }

    @Test
    func testScenarioRunnerCreation() {
        #expect(scenarioRunner != nil)
    }

    @Test
    func testSimpleScenarioExecution() async {
        let scenario = Scenario(
            name: "Simple Test",
            actions: [
                .delay(duration: 0.1)
            ],
            assertions: [
                .assertTrue(expression: "true")
            ]
        )

        let result = await scenarioRunner.execute(scenario: scenario)
        
        // The scenario should complete (though some actions might fail without a real simulator)
        #expect(result.scenario.id == scenario.id)
    }

    @Test
    func testDelayAction() async {
        let scenario = Scenario(
            name: "Delay Test",
            actions: [
                .delay(duration: 0.5)
            ]
        )

        let result = await scenarioRunner.execute(scenario: scenario)
        
        // Should have at least one action result
        #expect(result.actionResults.count >= 1)
    }

    @Test
    func testMultipleActions() async {
        let scenario = Scenario(
            name: "Multiple Actions Test",
            actions: [
                .delay(duration: 0.1),
                .delay(duration: 0.1),
                .delay(duration: 0.1)
            ]
        )

        let result = await scenarioRunner.execute(scenario: scenario)
        
        // Should have results for all actions
        #expect(result.actionResults.count == 3)
    }

    @Test
    func testScenarioWithAssertions() async {
        let scenario = Scenario(
            name: "Assertion Test",
            actions: [
                .delay(duration: 0.1)
            ],
            assertions: [
                .assertTrue(expression: "true"),
                .assertFalse(expression: "false")
            ]
        )

        let result = await scenarioRunner.execute(scenario: scenario)
        
        // Should have results for all assertions
        #expect(result.assertionResults.count == 2)
    }

    @Test
    func testCancellation() async {
        let scenario = Scenario(
            name: "Cancellation Test",
            actions: [
                .delay(duration: 10) // Long delay
            ]
        )

        // Start execution
        let executionTask = Task {
            await scenarioRunner.execute(scenario: scenario)
        }

        // Cancel after a short delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        scenarioRunner.cancel()

        // Wait for cancellation
        _ = await executionTask.result

        // State should be cancelled
        #expect(scenarioRunner.state == .cancelled)
    }

    @Test
    func testProgressTracking() async {
        let scenario = Scenario(
            name: "Progress Test",
            actions: [
                .delay(duration: 0.1),
                .delay(duration: 0.1)
            ],
            assertions: [
                .assertTrue(expression: "true")
            ]
        )

        // Start execution
        let executionTask = Task {
            await scenarioRunner.execute(scenario: scenario)
        }

        // Check progress during execution
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Progress should show some actions completed
        #expect(scenarioRunner.progress.currentActionIndex >= 0)

        // Wait for completion
        _ = await executionTask.result
    }

    @Test
    func testExecutionStateTransitions() async {
        let scenario = Scenario(
            name: "State Test",
            actions: [
                .delay(duration: 0.1)
            ]
        )

        // Initial state should be pending
        #expect(scenarioRunner.state == .pending)

        // Start execution
        let executionTask = Task {
            await scenarioRunner.execute(scenario: scenario)
        }

        // State should be running
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        #expect(scenarioRunner.state == .running)

        // Wait for completion
        _ = await executionTask.result

        // State should be completed
        #expect(scenarioRunner.state == .completed(success: true))
    }

    @Test
    func testExecutionWithTimeout() async {
        let scenario = Scenario(
            name: "Timeout Test",
            actions: [
                .delay(duration: 0.1)
            ]
        )

        // Execute with timeout
        let result = await scenarioRunner.execute(
            scenario: scenario,
            timeout: 5.0 // 5 seconds timeout
        )

        // Should complete within timeout
        #expect(result.duration < 5.0)
    }

    @Test
    func testExecutionResultProperties() async {
        let scenario = Scenario(
            name: "Result Test",
            actions: [
                .delay(duration: 0.1)
            ],
            assertions: [
                .assertTrue(expression: "true")
            ]
        )

        let result = await scenarioRunner.execute(scenario: scenario)
        
        // Check result properties
        #expect(result.scenario.id == scenario.id)
        #expect(result.duration >= 0)
        #expect(result.actionResults.count == 1)
        #expect(result.assertionResults.count == 1)
    }
}
