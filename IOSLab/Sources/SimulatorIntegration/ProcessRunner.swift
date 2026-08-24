import Foundation
import Core

/// Runs shell processes and captures output.
public final class ProcessRunner {
    private let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }

    /// Runs a command and returns the output.
    public func run(
        command: String,
        arguments: [String] = [],
        timeout: TimeInterval? = nil,
        workingDirectory: URL? = nil
    ) async throws -> ProcessResult {
        logger.debug("Running command: \(command) \(arguments)")

        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe

        if let workingDirectory = workingDirectory {
            process.currentDirectoryURL = workingDirectory
        }

        try process.run()

        // Handle timeout
        if let timeout = timeout {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            if process.isRunning {
                process.terminate()
                throw IOSLabError.processTimeout
            }
        } else {
            process.waitUntilExit()
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        let exitCode = process.terminationStatus

        if exitCode != 0 {
            throw IOSLabError.processFailed(
                exitCode: Int(exitCode),
                stdout: output,
                stderr: output
            )
        }

        logger.debug("Command succeeded with exit code: \(exitCode)")
        return ProcessResult(exitCode: Int(exitCode), output: output)
    }

    /// Runs a shell command (e.g., via /bin/zsh or /bin/bash).
    public func runShell(
        command: String,
        timeout: TimeInterval? = nil,
        workingDirectory: URL? = nil
    ) async throws -> ProcessResult {
        // Use shell to execute the command
        let shell = "/bin/zsh"
        let arguments = ["-c", command]

        return try await run(
            command: shell,
            arguments: arguments,
            timeout: timeout,
            workingDirectory: workingDirectory
        )
    }
}

public struct ProcessResult {
    public let exitCode: Int
    public let output: String
}
