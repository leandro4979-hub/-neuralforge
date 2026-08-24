import Testing
@testable import Core
@testable import ScenarioEngine

struct ScenarioValidatorTests {
    private let logger = Logger(component: "Test")
    private var validator: ScenarioValidator!

    init() {
        self.validator = ScenarioValidator(logger: logger)
    }

    @Test
    func testValidScenario() {
        let scenario = Scenario(
            name: "Test Scenario",
            actions: [
                .launchApp(bundleID: "com.example.app"),
                .tapElement(accessibilityIdentifier: "button1")
            ],
            assertions: [
                .assertVisibleText(text: "Hello, World!")
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.isEmpty)
    }

    @Test
    func testEmptyScenarioName() {
        let scenario = Scenario(name: "")
        let errors = validator.validate(scenario)
        #expect(errors.contains("Scenario name cannot be empty."))
    }

    @Test
    func testEmptyBundleID() {
        let scenario = Scenario(
            name: "Test Scenario",
            actions: [
                .launchApp(bundleID: "")
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.contains("Action 0: Bundle ID cannot be empty."))
    }

    @Test
    func testEmptyAccessibilityIdentifier() {
        let scenario = Scenario(
            name: "Test Scenario",
            actions: [
                .tapElement(accessibilityIdentifier: "")
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.contains("Action 0: Accessibility identifier cannot be empty."))
    }

    @Test
    func testNegativeDelay() {
        let scenario = Scenario(
            name: "Test Scenario",
            actions: [
                .delay(duration: -1)
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.contains("Action 0: Delay duration cannot be negative."))
    }

    @Test
    func testEmptyAssertionText() {
        let scenario = Scenario(
            name: "Test Scenario",
            assertions: [
                .assertVisibleText(text: "")
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.contains("Assertion 0: Text cannot be empty."))
    }

    @Test
    func testEmptyPushNotification() {
        let scenario = Scenario(
            name: "Test Scenario",
            actions: [
                .injectPushNotification(payload: ScenarioAction.PushNotificationPayload(title: "", body: ""))
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.contains("Action 0: Push notification must have a title or body."))
    }

    @Test
    func testValidPushNotification() {
        let scenario = Scenario(
            name: "Test Scenario",
            actions: [
                .injectPushNotification(payload: ScenarioAction.PushNotificationPayload(title: "Test", body: "Message"))
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.isEmpty)
    }

    @Test
    func testMultipleErrors() {
        let scenario = Scenario(
            name: "",
            actions: [
                .launchApp(bundleID: ""),
                .delay(duration: -1)
            ],
            assertions: [
                .assertVisibleText(text: "")
            ]
        )

        let errors = validator.validate(scenario)
        #expect(errors.count == 3)
    }
}
