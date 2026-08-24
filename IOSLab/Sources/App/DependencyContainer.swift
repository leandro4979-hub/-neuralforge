import Core
import SimulatorIntegration
import DeviceProfiles
import ScenarioEngine

/// Centralized dependency container for the app.
final class DependencyContainer {
    lazy var logger: Logger = {
        let logger = Logger(component: "IOSLab")
        logger.logLevel = .debug
        return logger
    }()

    lazy var processRunner: ProcessRunner = {
        ProcessRunner(logger: logger)
    }()

    lazy var simctlClient: SimctlClient = {
        SimctlClient(processRunner: processRunner, logger: logger)
    }()

    lazy var simulatorDiscovery: SimulatorDiscovery = {
        SimulatorDiscovery(simctlClient: simctlClient, logger: logger)
    }()

    lazy var simulatorLifecycleService: SimulatorLifecycleService = {
        SimulatorLifecycleService(simctlClient: simctlClient, logger: logger)
    }()

    lazy var deviceProfileStore: DeviceProfileStore = {
        DeviceProfileStore(logger: logger)
    }()

    lazy var scenarioParser: ScenarioParser = {
        ScenarioParser(logger: logger)
    }()

    lazy var scenarioValidator: ScenarioValidator = {
        ScenarioValidator(logger: logger)
    }()

    lazy var scenarioStore: ScenarioStore = {
        ScenarioStore(
            logger: logger,
            parser: scenarioParser,
            validator: scenarioValidator
        )
    }()

    lazy var appCoordinator: AppCoordinator = {
        AppCoordinator(logger: logger)
    }()

    // MARK: - Preview Support
    static var preview: DependencyContainer {
        let container = DependencyContainer()
        container.logger.logLevel = .debug
        return container
    }
}
