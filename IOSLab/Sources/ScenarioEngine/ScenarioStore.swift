import Foundation
import Core

/// Manages storage and retrieval of scenarios.
public final class ScenarioStore: ObservableObject {
    @Published public private(set) var scenarios: [Scenario] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: IOSLabError?

    private let logger: Logger
    private let scenariosURL: URL
    private let parser: ScenarioParser
    private let validator: ScenarioValidator

    public init(
        logger: Logger,
        scenariosURL: URL? = nil,
        parser: ScenarioParser? = nil,
        validator: ScenarioValidator? = nil
    ) {
        self.logger = logger
        self.scenariosURL = scenariosURL ?? defaultScenariosURL
        self.parser = parser ?? ScenarioParser(logger: logger)
        self.validator = validator ?? ScenarioValidator(logger: logger)
        loadScenarios()
    }

    // MARK: - Default Scenarios URL
    private static var defaultScenariosURL: URL {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let iosLabURL = appSupportURL.appendingPathComponent("IOSLab", isDirectory: true)
        try? fileManager.createDirectory(at: iosLabURL, withIntermediateDirectories: true)
        return iosLabURL.appendingPathComponent("Scenarios", isDirectory: true)
    }

    // MARK: - Load Scenarios
    public func loadScenarios() {
        isLoading = true
        error = nil

        do {
            let fileManager = FileManager.default
            
            // Create directory if it doesn't exist
            if !fileManager.fileExists(atPath: scenariosURL.path) {
                try fileManager.createDirectory(at: scenariosURL, withIntermediateDirectories: true)
            }
            
            let directoryContents = try fileManager.contentsOfDirectory(at: scenariosURL, includingPropertiesForKeys: nil)

            var loadedScenarios: [Scenario] = []
            for url in directoryContents {
                if url.pathExtension == "json" || url.pathExtension == "yaml" || url.pathExtension == "yml" {
                    let scenario = try parser.parseScenario(from: url)
                    loadedScenarios.append(scenario)
                }
            }

            scenarios = loadedScenarios.sorted { $0.name < $1.name }
        } catch {
            logger.error("Failed to load scenarios: \(error)")
            self.error = IOSLabError.internalError(error.localizedDescription)
            scenarios = []
        }

        isLoading = false
    }

    // MARK: - Save Scenario
    public func saveScenario(_ scenario: Scenario) throws {
        let url = scenariosURL.appendingPathComponent("\(scenario.id).json")
        try parser.writeScenario(scenario, to: url)
        loadScenarios()
    }

    // MARK: - Delete Scenario
    public func deleteScenario(_ scenario: Scenario) throws {
        let url = scenariosURL.appendingPathComponent("\(scenario.id).json")
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        loadScenarios()
    }

    // MARK: - Import Scenario
    public func importScenario(from url: URL) throws {
        let scenario = try parser.parseScenario(from: url)
        let errors = validator.validate(scenario)
        if !errors.isEmpty {
            throw IOSLabError.scenarioValidationFailed(errors)
        }

        // Check for duplicate name
        if scenarios.contains(where: { $0.name == scenario.name }) {
            throw IOSLabError.duplicateScenarioName(scenario.name)
        }

        let destinationURL = scenariosURL.appendingPathComponent("\(scenario.id).json")
        try parser.writeScenario(scenario, to: destinationURL)
        loadScenarios()
    }

    // MARK: - Export Scenario
    public func exportScenario(_ scenario: Scenario, to url: URL) throws {
        try parser.writeScenario(scenario, to: url)
    }

    // MARK: - Get Scenario by ID
    public func scenario(withID id: UUID) -> Scenario? {
        scenarios.first { $0.id == id }
    }
}
