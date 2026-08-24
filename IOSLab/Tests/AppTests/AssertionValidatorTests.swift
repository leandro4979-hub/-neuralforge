import Testing
@testable import Core
@testable import ScenarioEngine

struct AssertionValidatorTests {
    private let logger = Logger(component: "Test")
    private var assertionValidator: DefaultAssertionValidator!

    init() {
        self.assertionValidator = DefaultAssertionValidator(logger: logger)
    }

    @Test
    func testAssertTrueWithTrueExpression() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await assertionValidator.validate(
            assertion: .assertTrue(expression: "true"),
            context: context
        )

        #expect(result != nil)
        #expect(result?.passed == true)
    }

    @Test
    func testAssertFalseWithFalseExpression() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await assertionValidator.validate(
            assertion: .assertFalse(expression: "false"),
            context: context
        )

        #expect(result != nil)
        #expect(result?.passed == true)
    }

    @Test
    func testAssertVisibleText() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await assertionValidator.validate(
            assertion: .assertVisibleText(text: "Hello, World!"),
            context: context
        )

        #expect(result != nil)
        // In the mock implementation, this should pass
        #expect(result?.passed == true)
    }

    @Test
    func testAssertElementExists() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await assertionValidator.validate(
            assertion: .assertElementExists(accessibilityIdentifier: "button1"),
            context: context
        )

        #expect(result != nil)
        // In the mock implementation, this should pass
        #expect(result?.passed == true)
    }

    @Test
    func testAssertElementDoesNotExist() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await assertionValidator.validate(
            assertion: .assertElementDoesNotExist(accessibilityIdentifier: "nonexistent"),
            context: context
        )

        #expect(result != nil)
        // In the mock implementation, this should pass
        #expect(result?.passed == true)
    }

    @Test
    func testAssertNavigationState() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await assertionValidator.validate(
            assertion: .assertNavigationState(route: "/dashboard"),
            context: context
        )

        #expect(result != nil)
        // In the mock implementation, this checks against a hardcoded route
        #expect(result?.passed == true)
    }

    @Test
    func testAssertionResultProperties() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let result = try? await assertionValidator.validate(
            assertion: .assertTrue(expression: "true"),
            context: context
        )

        #expect(result?.assertion is ScenarioAssertion)
        #expect(result?.timestamp != nil)
        #expect(result?.message != nil)
    }

    @Test
    func testMultipleAssertions() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger
        )

        let assertions: [ScenarioAssertion] = [
            .assertTrue(expression: "true"),
            .assertFalse(expression: "false"),
            .assertVisibleText(text: "Test")
        ]

        for assertion in assertions {
            let result = try? await assertionValidator.validate(
                assertion: assertion,
                context: context
            )
            #expect(result?.passed == true)
        }
    }

    @Test
    func testAssertionWithCancelledContext() async {
        let context = ExecutionContext(
            scenario: Scenario(name: "Test"),
            logger: logger,
            cancellationToken: CancellationToken()
        )

        // Cancel the context
        context.cancellationToken.cancel()

        let result = try? await assertionValidator.validate(
            assertion: .assertTrue(expression: "true"),
            context: context
        )

        // Should fail due to cancellation
        #expect(result == nil)
    }
}
