import Foundation
import Core

/// Protocol for executing scenario actions.
public protocol ActionExecutor: AnyObject {
    /// Executes a scenario action.
    /// - Parameters:
    ///   - action: The action to execute.
    ///   - context: The execution context.
    /// - Returns: The result of the action execution.
    func execute(action: ScenarioAction, context: ExecutionContext) async throws -> ActionResult
}

/// Protocol for validating scenario assertions.
public protocol AssertionValidator: AnyObject {
    /// Validates a scenario assertion.
    /// - Parameters:
    ///   - assertion: The assertion to validate.
    ///   - context: The execution context.
    /// - Returns: The result of the assertion validation.
    func validate(assertion: ScenarioAssertion, context: ExecutionContext) async throws -> AssertionResult
}

/// Context for scenario execution.
public struct ExecutionContext {
    public let scenario: Scenario
    public let deviceProfile: DeviceProfile?
    public let simulatorInfo: SimulatorInfo?
    public let logger: Logger
    public var cancellationToken: CancellationToken
    
    public init(
        scenario: Scenario,
        deviceProfile: DeviceProfile? = nil,
        simulatorInfo: SimulatorInfo? = nil,
        logger: Logger,
        cancellationToken: CancellationToken = CancellationToken()
    ) {
        self.scenario = scenario
        self.deviceProfile = deviceProfile
        self.simulatorInfo = simulatorInfo
        self.logger = logger
        self.cancellationToken = cancellationToken
    }
}

/// Result of an action execution.
public struct ActionResult: Equatable {
    public let action: ScenarioAction
    public let success: Bool
    public let output: String?
    public let error: Error?
    public let timestamp: Date
    public let duration: TimeInterval

    public init(
        action: ScenarioAction,
        success: Bool,
        output: String? = nil,
        error: Error? = nil,
        timestamp: Date = Date(),
        duration: TimeInterval = 0
    ) {
        self.action = action
        self.success = success
        self.output = output
        self.error = error
        self.timestamp = timestamp
        self.duration = duration
    }
}

/// Result of an assertion validation.
public struct AssertionResult: Equatable {
    public let assertion: ScenarioAssertion
    public let passed: Bool
    public let message: String?
    public let error: Error?
    public let timestamp: Date

    public init(
        assertion: ScenarioAssertion,
        passed: Bool,
        message: String? = nil,
        error: Error? = nil,
        timestamp: Date = Date()
    ) {
        self.assertion = assertion
        self.passed = passed
        self.message = message
        self.error = error
        self.timestamp = timestamp
    }
}

/// Token for cancellation support.
public final class CancellationToken {
    private var isCancelled = false
    private let lock = NSLock()

    public var cancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return isCancelled
    }

    public func cancel() {
        lock.lock()
        defer { lock.unlock() }
        isCancelled = true
    }

    public func checkCancelled() throws {
        if cancelled {
            throw IOSLabError.unsupportedOperation("Operation was cancelled")
        }
    }
}

/// Execution state for a scenario.
public enum ExecutionState: Equatable {
    case pending
    case running
    case paused
    case cancelled
    case completed(success: Bool)
    case failed(error: Error)
}

/// Progress information for scenario execution.
public struct ExecutionProgress: Equatable {
    public let currentActionIndex: Int
    public let totalActions: Int
    public let currentAssertionIndex: Int
    public let totalAssertions: Int
    public let state: ExecutionState
    public let startTime: Date
    public let elapsedTime: TimeInterval

    public init(
        currentActionIndex: Int = 0,
        totalActions: Int = 0,
        currentAssertionIndex: Int = 0,
        totalAssertions: Int = 0,
        state: ExecutionState = .pending,
        startTime: Date = Date(),
        elapsedTime: TimeInterval = 0
    ) {
        self.currentActionIndex = currentActionIndex
        self.totalActions = totalActions
        self.currentAssertionIndex = currentAssertionIndex
        self.totalAssertions = totalAssertions
        self.state = state
        self.startTime = startTime
        self.elapsedTime = elapsedTime
    }
}
