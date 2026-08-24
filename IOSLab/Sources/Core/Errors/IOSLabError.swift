import Foundation

/// Custom errors for IOSLab.
public enum IOSLabError: Error, LocalizedError, Equatable {
    case processFailed(exitCode: Int, stdout: String?, stderr: String?)
    case processTimeout
    case invalidArgument(String)
    case fileNotFound(String)
    case permissionDenied(String)
    case unsupportedOperation(String)
    case internalError(String)
    case invalidScenario(String)
    case invalidDeviceProfile(String)
    case invalidJSON(String)
    case invalidYAML(String)
    case fileImportFailed(String)
    case fileExportFailed(String)
    case duplicateScenarioName(String)
    case scenarioValidationFailed([String])

    public var errorDescription: String? {
        switch self {
        case .processFailed(let exitCode, let stdout, let stderr):
            return "Process failed with exit code \(exitCode). Stdout: \(stdout ?? ""). Stderr: \(stderr ?? "")"
        case .processTimeout:
            return "Process execution timed out."
        case .invalidArgument(let message):
            return "Invalid argument: \(message)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .unsupportedOperation(let message):
            return "Unsupported operation: \(message)"
        case .internalError(let message):
            return "Internal error: \(message)"
        case .invalidScenario(let message):
            return "Invalid scenario: \(message)"
        case .invalidDeviceProfile(let message):
            return "Invalid device profile: \(message)"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        case .invalidYAML(let message):
            return "Invalid YAML: \(message)"
        case .fileImportFailed(let path):
            return "Failed to import file: \(path)"
        case .fileExportFailed(let path):
            return "Failed to export file: \(path)"
        case .duplicateScenarioName(let name):
            return "Duplicate scenario name: \(name)"
        case .scenarioValidationFailed(let errors):
            return "Scenario validation failed: \(errors.joined(separator: ", "))"
        }
    }
}
