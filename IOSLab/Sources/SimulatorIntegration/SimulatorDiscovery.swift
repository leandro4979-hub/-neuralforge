import Foundation
import Core

/// Discovers available iOS simulators.
public final class SimulatorDiscovery {
    private let simctlClient: SimctlClient
    private let logger: Logger

    public init(simctlClient: SimctlClient, logger: Logger) {
        self.simctlClient = simctlClient
        self.logger = logger
    }

    /// Discovers all available simulators.
    public func discoverSimulators() async throws -> [SimulatorInfo] {
        logger.info("Discovering iOS simulators...")
        
        do {
            let simulators = try await simctlClient.listDevices()
            logger.info("Found \(simulators.count) simulators")
            return simulators
        } catch {
            logger.error("Failed to discover simulators: \(error)")
            throw error
        }
    }

    /// Discovers available device types.
    public func discoverDeviceTypes() async throws -> [DeviceType] {
        logger.info("Discovering device types...")
        
        do {
            let deviceTypes = try await simctlClient.listDeviceTypes()
            logger.info("Found \(deviceTypes.count) device types")
            return deviceTypes
        } catch {
            logger.error("Failed to discover device types: \(error)")
            throw error
        }
    }

    /// Discovers available runtimes.
    public func discoverRuntimes() async throws -> [Runtime] {
        logger.info("Discovering runtimes...")
        
        do {
            let runtimes = try await simctlClient.listRuntimes()
            logger.info("Found \(runtimes.count) runtimes")
            return runtimes
        } catch {
            logger.error("Failed to discover runtimes: \(error)")
            throw error
        }
    }

    /// Finds a simulator by name.
    public func findSimulator(byName name: String) async throws -> SimulatorInfo? {
        let simulators = try await discoverSimulators()
        return simulators.first { $0.name == name }
    }

    /// Finds a simulator by UDID.
    public func findSimulator(byUDID udid: String) async throws -> SimulatorInfo? {
        let simulators = try await discoverSimulators()
        return simulators.first { $0.udid == udid }
    }

    /// Finds all simulators matching a device type.
    public func findSimulators(byDeviceType deviceType: String) async throws -> [SimulatorInfo] {
        let simulators = try await discoverSimulators()
        return simulators.filter { $0.deviceType == deviceType }
    }

    /// Finds all simulators matching a runtime.
    public func findSimulators(byRuntime runtime: String) async throws -> [SimulatorInfo] {
        let simulators = try await discoverSimulators()
        return simulators.filter { $0.runtime == runtime }
    }

    /// Checks if a simulator with the given name exists.
    public func simulatorExists(name: String) async throws -> Bool {
        return try await findSimulator(byName: name) != nil
    }
}
