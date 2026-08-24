import Foundation
import Core

/// Logs execution events for scenarios.
public final class ExecutionEventLogger {
    private let logger: Logger
    private var eventDelegates: [ExecutionEventDelegate] = []
    private let eventQueue = DispatchQueue(label: "com.ioslab.executionEvents", qos: .utility)
    private let eventSemaphore = DispatchSemaphore(value: 1)

    public init(logger: Logger) {
        self.logger = logger
    }

    /// Adds an event delegate.
    public func addEventDelegate(_ delegate: ExecutionEventDelegate) {
        eventSemaphore.wait()
        defer { eventSemaphore.signal() }
        eventDelegates.append(delegate)
    }

    /// Removes an event delegate.
    public func removeEventDelegate(_ delegate: ExecutionEventDelegate) {
        eventSemaphore.wait()
        defer { eventSemaphore.signal() }
        eventDelegates.removeAll { $0 === delegate }
    }

    /// Logs a scenario execution event.
    public func logEvent(_ event: ExecutionEvent) {
        eventQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Log to console
            self.logToConsole(event)
            
            // Notify delegates
            self.notifyDelegates(event)
        }
    }

    /// Logs scenario started event.
    public func logScenarioStarted(scenario: Scenario) {
        let event = ExecutionEvent(
            type: .scenarioStarted,
            scenarioID: scenario.id
        )
        logEvent(event)
    }

    /// Logs scenario completed event.
    public func logScenarioCompleted(scenario: Scenario, success: Bool) {
        let event = ExecutionEvent(
            type: .scenarioCompleted,
            scenarioID: scenario.id,
            message: success ? "Scenario completed successfully" : "Scenario completed with errors"
        )
        logEvent(event)
    }

    /// Logs scenario failed event.
    public func logScenarioFailed(scenario: Scenario, error: Error) {
        let event = ExecutionEvent(
            type: .scenarioFailed,
            scenarioID: scenario.id,
            error: error.localizedDescription
        )
        logEvent(event)
    }

    /// Logs scenario cancelled event.
    public func logScenarioCancelled(scenario: Scenario) {
        let event = ExecutionEvent(
            type: .scenarioCancelled,
            scenarioID: scenario.id,
            message: "Scenario execution was cancelled"
        )
        logEvent(event)
    }

    /// Logs action started event.
    public func logActionStarted(scenario: Scenario, action: ScenarioAction, index: Int) {
        let event = ExecutionEvent(
            type: .actionStarted,
            scenarioID: scenario.id,
            actionIndex: index,
            message: actionDescription(for: action)
        )
        logEvent(event)
    }

    /// Logs action completed event.
    public func logActionCompleted(scenario: Scenario, action: ScenarioAction, index: Int, result: ActionResult) {
        let event = ExecutionEvent(
            type: .actionCompleted,
            scenarioID: scenario.id,
            actionIndex: index,
            message: result.success ? "Action completed successfully" : "Action completed with error"
        )
        logEvent(event)
    }

    /// Logs action failed event.
    public func logActionFailed(scenario: Scenario, action: ScenarioAction, index: Int, error: Error) {
        let event = ExecutionEvent(
            type: .actionFailed,
            scenarioID: scenario.id,
            actionIndex: index,
            error: error.localizedDescription
        )
        logEvent(event)
    }

    /// Logs assertion started event.
    public func logAssertionStarted(scenario: Scenario, assertion: ScenarioAssertion, index: Int) {
        let event = ExecutionEvent(
            type: .assertionStarted,
            scenarioID: scenario.id,
            assertionIndex: index,
            message: assertionDescription(for: assertion)
        )
        logEvent(event)
    }

    /// Logs assertion completed event.
    public func logAssertionCompleted(scenario: Scenario, assertion: ScenarioAssertion, index: Int, result: AssertionResult) {
        let event = ExecutionEvent(
            type: .assertionCompleted,
            scenarioID: scenario.id,
            assertionIndex: index,
            message: result.passed ? "Assertion passed" : "Assertion failed"
        )
        logEvent(event)
    }

    /// Logs assertion failed event.
    public func logAssertionFailed(scenario: Scenario, assertion: ScenarioAssertion, index: Int, error: Error) {
        let event = ExecutionEvent(
            type: .assertionFailed,
            scenarioID: scenario.id,
            assertionIndex: index,
            error: error.localizedDescription
        )
        logEvent(event)
    }

    // MARK: - Private Methods

    private func logToConsole(_ event: ExecutionEvent) {
        let logLevel: Logger.LogLevel = {
            switch event.type {
            case .scenarioStarted, .actionStarted, .assertionStarted:
                return .info
            case .scenarioCompleted, .actionCompleted, .assertionCompleted:
                return .info
            case .scenarioFailed, .actionFailed, .assertionFailed:
                return .error
            case .scenarioCancelled:
                return .warning
            }
        }()

        var message = "[Execution] \(event.type.rawValue)"
        if let scenarioID = event.scenarioID {
            message += " [Scenario: \(scenarioID.uuidString.prefix(8))]"
        }
        if let actionIndex = event.actionIndex {
            message += " [Action: \(actionIndex)]"
        }
        if let assertionIndex = event.assertionIndex {
            message += " [Assertion: \(assertionIndex)]"
        }
        if let error = event.error {
            message += " [Error: \(error)]"
        }
        if let messageText = event.message {
            message += " [Message: \(messageText)]"
        }

        switch logLevel {
        case .debug: logger.debug(message)
        case .info: logger.info(message)
        case .warning: logger.warning(message)
        case .error: logger.error(message)
        case .critical: logger.critical(message)
        }
    }

    private func notifyDelegates(_ event: ExecutionEvent) {
        eventSemaphore.wait()
        let delegates = eventDelegates
        eventSemaphore.signal()

        for delegate in delegates {
            delegate.executionEvent(event)
        }
    }

    private func actionDescription(for action: ScenarioAction) -> String {
        switch action {
        case .launchApp(let bundleID): return "Launch App: \(bundleID)"
        case .tapElement(let identifier): return "Tap Element: \(identifier)"
        case .enterText(_, let identifier): return "Enter Text: \(identifier)"
        case .swipe(let direction, _): return "Swipe: \(direction)"
        case .rotateDevice(let orientation): return "Rotate Device: \(orientation)"
        case .changeNetworkProfile(let profile): return "Change Network: \(profile.profileType)"
        case .sendToBackground: return "Send to Background"
        case .sendToForeground: return "Send to Foreground"
        case .injectPushNotification(let payload): return "Push Notification: \(payload.title)"
        case .simulateLocationUpdate(let lat, let lon): return "Location Update: (\(lat), \(lon))"
        case .captureScreenshot(let name): return "Capture Screenshot: \(name ?? "unnamed")"
        case .delay(let duration): return "Delay: \(duration)s"
        case .custom(let command): return "Custom: \(command)"
        }
    }

    private func assertionDescription(for assertion: ScenarioAssertion) -> String {
        switch assertion {
        case .assertVisibleText(let text): return "Assert Visible Text: \(text)"
        case .assertAccessibilityLabel(let label): return "Assert Label: \(label)"
        case .assertElementExists(let identifier): return "Assert Element Exists: \(identifier)"
        case .assertElementDoesNotExist(let identifier): return "Assert Element Not Exists: \(identifier)"
        case .assertNavigationState(let route): return "Assert Navigation: \(route)"
        case .assertAPIRequestData(let endpoint, _): return "Assert API: \(endpoint)"
        case .assertScreenshotMatchesBaseline(let name): return "Assert Screenshot: \(name)"
        case .assertTrue(let expression): return "Assert True: \(expression)"
        case .assertFalse(let expression): return "Assert False: \(expression)"
        }
    }
}

/// Extension to ScenarioRunner for event logging.
extension ScenarioRunner {
    private var eventLogger: ExecutionEventLogger?

    /// Sets the event logger.
    public func setEventLogger(_ logger: ExecutionEventLogger) {
        self.eventLogger = logger
    }

    /// Override execute to add event logging.
    public func executeWithLogging(
        scenario: Scenario,
        deviceProfileID: UUID? = nil,
        simulatorUDID: String? = nil,
        timeout: TimeInterval? = nil
    ) async -> ExecutionResult {
        eventLogger?.logScenarioStarted(scenario: scenario)

        let result = await execute(
            scenario: scenario,
            deviceProfileID: deviceProfileID,
            simulatorUDID: simulatorUDID,
            timeout: timeout
        )

        if result.success {
            eventLogger?.logScenarioCompleted(scenario: scenario, success: true)
        } else if let error = result.error {
            eventLogger?.logScenarioFailed(scenario: scenario, error: error)
        }

        return result
    }
}
