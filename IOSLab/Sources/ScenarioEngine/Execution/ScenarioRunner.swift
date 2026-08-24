import Foundation
import Core
import SimulatorIntegration

/// Executes scenarios deterministically.
public final class ScenarioRunner: ObservableObject {
    @Published public private(set) var progress: ExecutionProgress = ExecutionProgress()
    @Published public private(set) var actionResults: [ActionResult] = []
    @Published public private(set) var assertionResults: [AssertionResult] = []
    @Published public private(set) var state: ExecutionState = .pending
    @Published public private(set) var error: Error?

    private let actionExecutor: ActionExecutor
    private let assertionValidator: AssertionValidator
    private let logger: Logger
    private let deviceProfileStore: DeviceProfileStore
    private let simctlClient: SimctlClient

    public init(
        actionExecutor: ActionExecutor,
        assertionValidator: AssertionValidator,
        logger: Logger,
        deviceProfileStore: DeviceProfileStore,
        simctlClient: SimctlClient
    ) {
        self.actionExecutor = actionExecutor
        self.assertionValidator = assertionValidator
        self.logger = logger
        self.deviceProfileStore = deviceProfileStore
        self.simctlClient = simctlClient
    }

    /// Executes a scenario.
    /// - Parameters:
    ///   - scenario: The scenario to execute.
    ///   - deviceProfileID: Optional device profile ID to use.
    ///   - simulatorUDID: Optional simulator UDID to use.
    ///   - timeout: Optional timeout for the entire scenario execution.
    /// - Returns: The final execution result.
    public func execute(
        scenario: Scenario,
        deviceProfileID: UUID? = nil,
        simulatorUDID: String? = nil,
        timeout: TimeInterval? = nil
    ) async -> ExecutionResult {
        // Reset state
        actionResults.removeAll()
        assertionResults.removeAll()
        error = nil

        // Get device profile
        let deviceProfile: DeviceProfile?
        if let deviceProfileID = deviceProfileID {
            deviceProfile = deviceProfileStore.profile(withID: deviceProfileID)
        } else if let id = scenario.deviceProfileID {
            deviceProfile = deviceProfileStore.profile(withID: id)
        } else {
            deviceProfile = nil
        }

        // Get simulator info
        let simulatorInfo: SimulatorInfo?
        if let simulatorUDID = simulatorUDID {
            let simulators = try? await simctlClient.listDevices()
            simulatorInfo = simulators?.first { $0.udid == simulatorUDID }
        } else {
            simulatorInfo = nil
        }

        // Create execution context
        let cancellationToken = CancellationToken()
        let context = ExecutionContext(
            scenario: scenario,
            deviceProfile: deviceProfile,
            simulatorInfo: simulatorInfo,
            logger: logger,
            cancellationToken: cancellationToken
        )

        // Update progress
        updateProgress(
            currentActionIndex: 0,
            totalActions: scenario.actions.count,
            currentAssertionIndex: 0,
            totalAssertions: scenario.assertions.count,
            state: .running,
            startTime: Date()
        )

        logger.info("Starting scenario execution: \(scenario.name)")

        do {
            // Execute actions
            for (index, action) in scenario.actions.enumerated() {
                try await executeAction(action, index: index, context: context, scenario: scenario)
            }

            // Execute assertions
            for (index, assertion) in scenario.assertions.enumerated() {
                try await executeAssertion(assertion, index: index, context: context, scenario: scenario)
            }

            // Check for timeout
            if let timeout = timeout {
                let elapsed = Date().timeIntervalSince(context.startTime)
                if elapsed > timeout {
                    throw IOSLabError.processTimeout
                }
            }

            logger.info("Scenario execution completed successfully: \(scenario.name)")
            updateState(.completed(success: true))

            return ExecutionResult(
                scenario: scenario,
                success: true,
                actionResults: actionResults,
                assertionResults: assertionResults,
                duration: Date().timeIntervalSince(context.startTime)
            )

        } catch let error as IOSLabError {
            logger.error("Scenario execution failed: \(error)")
            self.error = error
            updateState(.failed(error: error))

            return ExecutionResult(
                scenario: scenario,
                success: false,
                actionResults: actionResults,
                assertionResults: assertionResults,
                duration: Date().timeIntervalSince(context.startTime),
                error: error
            )

        } catch {
            logger.error("Scenario execution failed with unexpected error: \(error)")
            self.error = error
            updateState(.failed(error: error))

            return ExecutionResult(
                scenario: scenario,
                success: false,
                actionResults: actionResults,
                assertionResults: assertionResults,
                duration: Date().timeIntervalSince(context.startTime),
                error: error
            )
        }
    }

    /// Cancels the current scenario execution.
    public func cancel() {
        logger.info("Cancelling scenario execution")
        updateState(.cancelled)
    }

    /// Pauses the current scenario execution.
    public func pause() {
        logger.info("Pausing scenario execution")
        updateState(.paused)
    }

    /// Resumes the current scenario execution.
    public func resume() {
        logger.info("Resuming scenario execution")
        updateState(.running)
    }

    // MARK: - Private Methods

    private func executeAction(_ action: ScenarioAction, index: Int, context: ExecutionContext, scenario: Scenario) async throws {
        try context.cancellationToken.checkCancelled()

        updateProgress(
            currentActionIndex: index,
            totalActions: scenario.actions.count,
            currentAssertionIndex: 0,
            totalAssertions: scenario.assertions.count,
            state: .running,
            startTime: context.startTime
        )

        logger.debug("Executing action \(index): \(action)")

        let result = try await actionExecutor.execute(action: action, context: context)
        actionResults.append(result)

        if !result.success {
            logger.warning("Action \(index) failed: \(result.error?.localizedDescription ?? "Unknown error")")
        }
    }

    private func executeAssertion(_ assertion: ScenarioAssertion, index: Int, context: ExecutionContext, scenario: Scenario) async throws {
        try context.cancellationToken.checkCancelled()

        updateProgress(
            currentActionIndex: scenario.actions.count,
            totalActions: scenario.actions.count,
            currentAssertionIndex: index,
            totalAssertions: scenario.assertions.count,
            state: .running,
            startTime: context.startTime
        )

        logger.debug("Validating assertion \(index): \(assertion)")

        let result = try await assertionValidator.validate(assertion: assertion, context: context)
        assertionResults.append(result)

        if !result.passed {
            logger.warning("Assertion \(index) failed: \(result.message ?? "No message")")
        }
    }

    private func updateProgress(
        currentActionIndex: Int,
        totalActions: Int,
        currentAssertionIndex: Int,
        totalAssertions: Int,
        state: ExecutionState,
        startTime: Date
    ) {
        progress = ExecutionProgress(
            currentActionIndex: currentActionIndex,
            totalActions: totalActions,
            currentAssertionIndex: currentAssertionIndex,
            totalAssertions: totalAssertions,
            state: state,
            startTime: startTime,
            elapsedTime: Date().timeIntervalSince(startTime)
        )
    }

    private func updateState(_ state: ExecutionState) {
        self.state = state
        progress.state = state
    }
}

/// Result of a scenario execution.
public struct ExecutionResult: Equatable {
    public let scenario: Scenario
    public let success: Bool
    public let actionResults: [ActionResult]
    public let assertionResults: [AssertionResult]
    public let duration: TimeInterval
    public let error: Error?

    public init(
        scenario: Scenario,
        success: Bool,
        actionResults: [ActionResult],
        assertionResults: [AssertionResult],
        duration: TimeInterval,
        error: Error? = nil
    ) {
        self.scenario = scenario
        self.success = success
        self.actionResults = actionResults
        self.assertionResults = assertionResults
        self.duration = duration
        self.error = error
    }
}

// MARK: - Execution Event Types

/// Types of events that can occur during scenario execution.
public enum ExecutionEventType: String, Codable, Equatable {
    case scenarioStarted
    case scenarioCompleted
    case scenarioFailed
    case scenarioCancelled
    case actionStarted
    case actionCompleted
    case actionFailed
    case assertionStarted
    case assertionCompleted
    case assertionFailed
}

/// Event emitted during scenario execution.
public struct ExecutionEvent: Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: ExecutionEventType
    public let timestamp: Date
    public let scenarioID: UUID
    public let actionIndex: Int?
    public let assertionIndex: Int?
    public let message: String?
    public let error: String?

    public init(
        id: UUID = UUID(),
        type: ExecutionEventType,
        timestamp: Date = Date(),
        scenarioID: UUID,
        actionIndex: Int? = nil,
        assertionIndex: Int? = nil,
        message: String? = nil,
        error: String? = nil
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.scenarioID = scenarioID
        self.actionIndex = actionIndex
        self.assertionIndex = assertionIndex
        self.message = message
        self.error = error
    }
}

/// Delegate protocol for receiving execution events.
public protocol ExecutionEventDelegate: AnyObject {
    func executionEvent(_ event: ExecutionEvent)
}
