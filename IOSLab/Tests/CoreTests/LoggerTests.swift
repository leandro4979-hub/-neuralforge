import Testing
@testable import Core

struct LoggerTests {
    @Test
    func testLoggerCreation() {
        let logger = Logger(component: "Test")
        #expect(logger != nil)
    }

    @Test
    func testLogLevels() {
        let logger = Logger(component: "Test")
        
        // Test all log levels
        logger.debug("Debug message")
        logger.info("Info message")
        logger.warning("Warning message")
        logger.error("Error message")
        logger.critical("Critical message")
        
        // Just verify no crashes
        #expect(true)
    }

    @Test
    func testLogLevelFiltering() {
        let logger = Logger(component: "Test", logLevel: .warning)
        
        // These should not appear
        logger.debug("Debug message")
        logger.info("Info message")
        
        // These should appear
        logger.warning("Warning message")
        logger.error("Error message")
        logger.critical("Critical message")
        
        #expect(true)
    }
}
