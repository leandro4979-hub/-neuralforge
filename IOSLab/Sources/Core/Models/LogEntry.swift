import Foundation

/// Represents a log entry in IOSLab.
public struct LogEntry: Identifiable, Codable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let level: LogLevel
    public let component: String
    public let message: String
    public let metadata: [String: String]?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: LogLevel,
        component: String,
        message: String,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.component = component
        self.message = message
        self.metadata = metadata
    }

    public enum LogLevel: String, Codable, Equatable {
        case debug
        case info
        case warning
        case error
        case critical
    }
}
