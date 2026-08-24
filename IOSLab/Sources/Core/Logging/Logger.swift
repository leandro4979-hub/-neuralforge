import Foundation
import os.log

/// Logger for IOSLab.
public final class Logger {
    private let osLogger: OSLog
    public var logLevel: LogLevel

    public init(component: String, logLevel: LogLevel = .info) {
        self.osLogger = OSLog(subsystem: "com.ioslab", category: component)
        self.logLevel = logLevel
    }

    public enum LogLevel: String {
        case debug
        case info
        case warning
        case error
        case critical
    }

    public func debug(_ message: String, metadata: [String: Any]? = nil) {
        guard logLevel.rawValue == "debug" || shouldLog(.debug) else { return }
        var formattedMessage = "[DEBUG] \(message)"
        if let metadata = metadata {
            formattedMessage += " \(metadata)"
        }
        os_log("%{public}@", log: osLogger, type: .debug, formattedMessage)
    }

    public func info(_ message: String, metadata: [String: Any]? = nil) {
        guard shouldLog(.info) else { return }
        var formattedMessage = "[INFO] \(message)"
        if let metadata = metadata {
            formattedMessage += " \(metadata)"
        }
        os_log("%{public}@", log: osLogger, type: .info, formattedMessage)
    }

    public func warning(_ message: String, metadata: [String: Any]? = nil) {
        guard shouldLog(.warning) else { return }
        var formattedMessage = "[WARNING] \(message)"
        if let metadata = metadata {
            formattedMessage += " \(metadata)"
        }
        os_log("%{public}@", log: osLogger, type: .default, formattedMessage)
    }

    public func error(_ message: String, metadata: [String: Any]? = nil) {
        guard shouldLog(.error) else { return }
        var formattedMessage = "[ERROR] \(message)"
        if let metadata = metadata {
            formattedMessage += " \(metadata)"
        }
        os_log("%{public}@", log: osLogger, type: .error, formattedMessage)
    }

    public func critical(_ message: String, metadata: [String: Any]? = nil) {
        guard shouldLog(.critical) else { return }
        var formattedMessage = "[CRITICAL] \(message)"
        if let metadata = metadata {
            formattedMessage += " \(metadata)"
        }
        os_log("%{public}@", log: osLogger, type: .fault, formattedMessage)
    }

    private func shouldLog(_ level: LogLevel) -> Bool {
        let levels: [LogLevel] = [.debug, .info, .warning, .error, .critical]
        guard let currentIndex = levels.firstIndex(of: logLevel),
              let targetIndex = levels.firstIndex(of: level) else {
            return false
        }
        return targetIndex >= currentIndex
    }
}
