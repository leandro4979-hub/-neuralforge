import Foundation
import Core

/// Client for interacting with `xcrun simctl` commands.
public final class SimctlClient {
    private let processRunner: ProcessRunner
    private let logger: Logger

    public init(processRunner: ProcessRunner, logger: Logger) {
        self.processRunner = processRunner
        self.logger = logger
    }

    /// Lists all available simulators.
    public func listDevices() async throws -> [SimulatorInfo] {
        let result = try await processRunner.runShell(command: "xcrun simctl list devices --json")
        
        guard let data = result.output.data(using: .utf8) else {
            throw IOSLabError.internalError("Failed to parse simctl output")
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(SimctlListResponse.self, from: data)

        return response.devices.runtimes.flatMap { runtime in
            runtime.devices.map { device in
                SimulatorInfo(
                    udid: device.udid,
                    name: device.name,
                    deviceType: device.deviceType,
                    runtime: runtime.identifier,
                    state: mapState(device.state),
                    isAvailable: device.isAvailable
                )
            }
        }
    }

    /// Boots a simulator.
    public func bootDevice(udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl boot \(udid)")
    }

    /// Shuts down a simulator.
    public func shutdownDevice(udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl shutdown \(udid)")
    }

    /// Erases a simulator.
    public func eraseDevice(udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl erase \(udid)")
    }

    /// Creates a new simulator.
    public func createDevice(
        name: String,
        deviceType: String,
        runtime: String
    ) async throws -> SimulatorInfo {
        let result = try await processRunner.runShell(
            command: "xcrun simctl create \"\(name)\" \"\(deviceType)\" \"\(runtime)\" --json"
        )

        guard let data = result.output.data(using: .utf8) else {
            throw IOSLabError.internalError("Failed to parse simctl create output")
        }

        let decoder = JSONDecoder()
        let device = try decoder.decode(SimctlDevice.self, from: data)

        return SimulatorInfo(
            udid: device.udid,
            name: name,
            deviceType: deviceType,
            runtime: runtime,
            state: .shutdown,
            isAvailable: true
        )
    }

    /// Deletes a simulator.
    public func deleteDevice(udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl delete \(udid)")
    }

    /// Lists available device types.
    public func listDeviceTypes() async throws -> [DeviceType] {
        let result = try await processRunner.runShell(command: "xcrun simctl list devicetypes --json")
        
        guard let data = result.output.data(using: .utf8) else {
            throw IOSLabError.internalError("Failed to parse simctl output")
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(SimctlDeviceTypesResponse.self, from: data)

        return response.deviceTypes
    }

    /// Lists available runtimes.
    public func listRuntimes() async throws -> [Runtime] {
        let result = try await processRunner.runShell(command: "xcrun simctl list runtimes --json")
        
        guard let data = result.output.data(using: .utf8) else {
            throw IOSLabError.internalError("Failed to parse simctl output")
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(SimctlRuntimesResponse.self, from: data)

        return response.runtimes
    }

    /// Opens a URL in a simulator.
    public func openURL(_ url: String, udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl openurl \(udid) \"\(url)\"")
    }

    /// Installs an app on a simulator.
    public func installApp(_ appPath: String, udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl install \(udid) \"\(appPath)\"")
    }

    /// Uninstalls an app from a simulator.
    public func uninstallApp(_ bundleID: String, udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl uninstall \(udid) \"\(bundleID)\"")
    }

    /// Launches an app on a simulator.
    public func launchApp(_ bundleID: String, udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl launch \(udid) \"\(bundleID)\"")
    }

    /// Terminates an app on a simulator.
    public func terminateApp(_ bundleID: String, udid: String) async throws {
        try await processRunner.runShell(command: "xcrun simctl terminate \(udid) \"\(bundleID)\"")
    }

    // MARK: - Private Helpers

    private func mapState(_ state: String) -> SimulatorInfo.SimulatorState {
        switch state.lowercased() {
        case "booted": return .booted
        case "shutdown": return .shutdown
        case "shutting down": return .shuttingDown
        case "booting": return .booting
        case "creating": return .creating
        case "not installed": return .notInstalled
        default: return .unknown
        }
    }
}

// MARK: - Response Models

struct SimctlListResponse: Codable {
    let devices: DevicesResponse
}

struct DevicesResponse: Codable {
    let runtimes: [RuntimeResponse]
}

struct RuntimeResponse: Codable {
    let identifier: String
    let buildversion: String
    let version: String
    let isAvailable: Bool
    let devices: [DeviceResponse]
}

struct DeviceResponse: Codable {
    let udid: String
    let isAvailable: Bool
    let name: String
    let state: String
    let deviceType: String
}

struct SimctlDevice: Codable {
    let udid: String
}

struct SimctlDeviceTypesResponse: Codable {
    let deviceTypes: [DeviceType]
}

public struct DeviceType: Codable, Identifiable {
    public let id = UUID()
    public let name: String
    public let identifier: String
    public let productFamily: String

    public init(name: String, identifier: String, productFamily: String) {
        self.name = name
        self.identifier = identifier
        self.productFamily = productFamily
    }
}

struct SimctlRuntimesResponse: Codable {
    let runtimes: [Runtime]
}

public struct Runtime: Codable, Identifiable {
    public let id = UUID()
    public let identifier: String
    public let buildversion: String
    public let version: String
    public let isAvailable: Bool
    public let name: String

    public init(identifier: String, buildversion: String, version: String, isAvailable: Bool, name: String) {
        self.identifier = identifier
        self.buildversion = buildversion
        self.version = version
        self.isAvailable = isAvailable
        self.name = name
    }
}
