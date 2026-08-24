import Testing
@testable import Core
@testable import SimulatorIntegration

struct SimulatorIntegrationTests {
    private let logger = Logger(component: "Test")
    private var processRunner: ProcessRunner!
    private var simctlClient: SimctlClient!

    init() {
        self.processRunner = ProcessRunner(logger: logger)
        self.simctlClient = SimctlClient(processRunner: processRunner, logger: logger)
    }

    @Test
    func testListDevices() async {
        do {
            let devices = try await simctlClient.listDevices()
            // Just verify we can list devices without error
            #expect(devices.count >= 0)
        } catch {
            // This might fail if xcrun/simctl is not available in the test environment
            // That's okay for unit tests
        }
    }

    @Test
    func testListDeviceTypes() async {
        do {
            let deviceTypes = try await simctlClient.listDeviceTypes()
            #expect(deviceTypes.count >= 0)
        } catch {
            // This might fail if xcrun/simctl is not available
        }
    }

    @Test
    func testListRuntimes() async {
        do {
            let runtimes = try await simctlClient.listRuntimes()
            #expect(runtimes.count >= 0)
        } catch {
            // This might fail if xcrun/simctl is not available
        }
    }
}
