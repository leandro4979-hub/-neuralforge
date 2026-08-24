import Foundation
import Yams
import Core

/// Parses scenario files (JSON or YAML).
public final class ScenarioParser {
    private let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    /// Parses a scenario from a JSON or YAML string.
    public func parseScenario(from string: String, format: ScenarioFormat) throws -> Scenario {
        switch format {
        case .json:
            return try parseJSON(string)
        case .yaml:
            return try parseYAML(string)
        }
    }

    /// Parses a scenario from a JSON string.
    private func parseJSON(_ string: String) throws -> Scenario {
        let data = string.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Scenario.self, from: data)
    }

    /// Parses a scenario from a YAML string.
    private func parseYAML(_ string: String) throws -> Scenario {
        guard let yaml = try Yams.load(yaml: string) else {
            throw IOSLabError.invalidYAML("Failed to parse YAML")
        }

        let data = try JSONSerialization.data(withJSONObject: yaml, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Scenario.self, from: data)
    }

    /// Parses a scenario from a file URL.
    public func parseScenario(from url: URL) throws -> Scenario {
        let data = try Data(contentsOf: url)
        let string = String(data: data, encoding: .utf8) ?? ""

        if url.pathExtension == "yaml" || url.pathExtension == "yml" {
            return try parseYAML(string)
        } else {
            return try parseJSON(string)
        }
    }

    /// Serializes a scenario to a JSON or YAML string.
    public func serializeScenario(_ scenario: Scenario, format: ScenarioFormat) throws -> String {
        switch format {
        case .json:
            return try serializeJSON(scenario)
        case .yaml:
            return try serializeYAML(scenario)
        }
    }

    /// Serializes a scenario to a JSON string.
    private func serializeJSON(_ scenario: Scenario) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(scenario)
        return String(data: data, encoding: .utf8)!
    }

    /// Serializes a scenario to a YAML string.
    private func serializeYAML(_ scenario: Scenario) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(scenario)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return try Yams.dump(object: json)
    }

    /// Writes a scenario to a file URL.
    public func writeScenario(_ scenario: Scenario, to url: URL) throws {
        let format: ScenarioFormat = url.pathExtension == "yaml" || url.pathExtension == "yml" ? .yaml : .json
        let string = try serializeScenario(scenario, format: format)
        try string.write(to: url, atomically: true, encoding: .utf8)
    }
}

public enum ScenarioFormat: String, Codable, Equatable {
    case json
    case yaml
}
