import Foundation
import Core

/// Validates scenarios for correctness.
public final class ScenarioValidator {
    private let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    /// Validates a scenario and returns any errors.
    public func validate(_ scenario: Scenario) -> [String] {
        var errors: [String] = []

        // Validate name
        if scenario.name.isEmpty {
            errors.append("Scenario name cannot be empty.")
        }

        // Validate actions
        for (index, action) in scenario.actions.enumerated() {
            let actionErrors = validateAction(action, index: index)
            errors.append(contentsOf: actionErrors)
        }

        // Validate assertions
        for (index, assertion) in scenario.assertions.enumerated() {
            let assertionErrors = validateAssertion(assertion, index: index)
            errors.append(contentsOf: assertionErrors)
        }

        return errors
    }

    /// Validates a single action.
    private func validateAction(_ action: ScenarioAction, index: Int) -> [String] {
        var errors: [String] = []

        switch action {
        case .launchApp(let bundleID):
            if bundleID.isEmpty {
                errors.append("Action \(index): Bundle ID cannot be empty.")
            }
        case .tapElement(let accessibilityIdentifier):
            if accessibilityIdentifier.isEmpty {
                errors.append("Action \(index): Accessibility identifier cannot be empty.")
            }
        case .enterText(let text, let accessibilityIdentifier):
            if accessibilityIdentifier.isEmpty {
                errors.append("Action \(index): Accessibility identifier cannot be empty.")
            }
        case .swipe(_, let accessibilityIdentifier):
            if let accessibilityIdentifier = accessibilityIdentifier, accessibilityIdentifier.isEmpty {
                errors.append("Action \(index): Accessibility identifier cannot be empty.")
            }
        case .injectPushNotification(let payload):
            if payload.title.isEmpty && payload.body.isEmpty {
                errors.append("Action \(index): Push notification must have a title or body.")
            }
        case .captureScreenshot(let name):
            if let name = name, name.isEmpty {
                errors.append("Action \(index): Screenshot name cannot be empty.")
            }
        case .delay(let duration):
            if duration < 0 {
                errors.append("Action \(index): Delay duration cannot be negative.")
            }
        default:
            break
        }

        return errors
    }

    /// Validates a single assertion.
    private func validateAssertion(_ assertion: ScenarioAssertion, index: Int) -> [String] {
        var errors: [String] = []

        switch assertion {
        case .assertVisibleText(let text):
            if text.isEmpty {
                errors.append("Assertion \(index): Text cannot be empty.")
            }
        case .assertAccessibilityLabel(let label):
            if label.isEmpty {
                errors.append("Assertion \(index): Accessibility label cannot be empty.")
            }
        case .assertElementExists(let accessibilityIdentifier):
            if accessibilityIdentifier.isEmpty {
                errors.append("Assertion \(index): Accessibility identifier cannot be empty.")
            }
        case .assertElementDoesNotExist(let accessibilityIdentifier):
            if accessibilityIdentifier.isEmpty {
                errors.append("Assertion \(index): Accessibility identifier cannot be empty.")
            }
        case .assertNavigationState(let route):
            if route.isEmpty {
                errors.append("Assertion \(index): Route cannot be empty.")
            }
        case .assertAPIRequestData(let endpoint, _):
            if endpoint.isEmpty {
                errors.append("Assertion \(index): Endpoint cannot be empty.")
            }
        case .assertScreenshotMatchesBaseline(let name):
            if name.isEmpty {
                errors.append("Assertion \(index): Baseline name cannot be empty.")
            }
        case .assertTrue(let expression):
            if expression.isEmpty {
                errors.append("Assertion \(index): Expression cannot be empty.")
            }
        case .assertFalse(let expression):
            if expression.isEmpty {
                errors.append("Assertion \(index): Expression cannot be empty.")
            }
        }

        return errors
    }
}
