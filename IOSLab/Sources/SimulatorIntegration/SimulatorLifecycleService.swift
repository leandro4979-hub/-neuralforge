import Foundation
import Core

/// Manages the lifecycle of iOS simulators.
public final class SimulatorLifecycleService {
    private let simctlClient: SimctlClient
    private let logger: Logger

    public init(simctlClient: SimctlClient, logger: Logger) {
        self.simctlClient = simctlClient
        self.logger = logger
    }

    /// Creates a new simulator.
    public func createSimulator(
        name: String,
        deviceType: String,
        runtime: String
    ) async throws -> SimulatorInfo {
        logger.info("Creating simulator: \(name), deviceType: \(deviceType), runtime: \(runtime)")
        
        do {
            let simulator = try await simctlClient.createDevice(
                name: name,
                deviceType: deviceType,
                runtime: runtime
            )
            logger.info("Successfully created simulator: \(simulator.udid)")
            return simulator
        } catch {
            logger.error("Failed to create simulator: \(error)")
            throw error
        }
    }

    /// Boots a simulator.
    public func bootSimulator(udid: String) async throws {
        logger.info("Booting simulator: \(udid)")
        
        do {
            try await simctlClient.bootDevice(udid: udid)
            logger.info("Successfully booted simulator: \(udid)")
        } catch {
            logger.error("Failed to boot simulator: \(error)")
            throw error
        }
    }

    /// Shuts down a simulator.
    public func shutdownSimulator(udid: String) async throws {
        logger.info("Shutting down simulator: \(udid)")
        
        do {
            try await simctlClient.shutdownDevice(udid: udid)
            logger.info("Successfully shut down simulator: \(udid)")
        } catch {
            logger.error("Failed to shut down simulator: \(error)")
            throw error
        }
    }

    /// Erases a simulator.
    public func eraseSimulator(udid: String) async throws {
        logger.info("Erasing simulator: \(udid)")
        
        do {
            try await simctlClient.eraseDevice(udid: udid)
            logger.info("Successfully erased simulator: \(udid)")
        } catch {
            logger.error("Failed to erase simulator: \(error)")
            throw error
        }
    }

    /// Deletes a simulator.
    public func deleteSimulator(udid: String) async throws {
        logger.info("Deleting simulator: \(udid)")
        
        do {
            try await simctlClient.deleteDevice(udid: udid)
            logger.info("Successfully deleted simulator: \(udid)")
        } catch {
            logger.error("Failed to delete simulator: \(error)")
            throw error
        }
    }

    /// Ensures a simulator is in the booted state.
    public func ensureBooted(udid: String) async throws {
        // Check current state
        let simulators = try await simctlClient.listDevices()
        guard let simulator = simulators.first(where: { $0.udid == udid }) else {
            throw IOSLabError.invalidArgument("Simulator with UDID \(udid) not found")
        }

        switch simulator.state {
        case .booted:
            logger.info("Simulator \(udid) is already booted")
            return
        case .shutdown:
            try await bootSimulator(udid: udid)
        case .booting:
            // Wait for boot to complete
            logger.info("Simulator \(udid) is booting, waiting...")
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            try await ensureBooted(udid: udid)
        case .shuttingDown:
            // Wait for shutdown to complete, then boot
            logger.info("Simulator \(udid) is shutting down, waiting...")
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            try await ensureBooted(udid: udid)
        case .creating, .notInstalled, .unknown:
            throw IOSLabError.unsupportedOperation("Cannot boot simulator in state: \(simulator.state)")
        }
    }

    /// Ensures a simulator is in the shutdown state.
    public func ensureShutdown(udid: String) async throws {
        let simulators = try await simctlClient.listDevices()
        guard let simulator = simulators.first(where: { $0.udid == udid }) else {
            throw IOSLabError.invalidArgument("Simulator with UDID \(udid) not found")
        }

        switch simulator.state {
        case .shutdown:
            logger.info("Simulator \(udid) is already shut down")
            return
        case .booted:
            try await shutdownSimulator(udid: udid)
        case .shuttingDown:
            // Wait for shutdown to complete
            logger.info("Simulator \(udid) is shutting down, waiting...")
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            try await ensureShutdown(udid: udid)
        case .booting:
            // Wait for boot to complete, then shut down
            logger.info("Simulator \(udid) is booting, waiting...")
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            try await ensureShutdown(udid: udid)
        case .creating, .notInstalled, .unknown:
            throw IOSLabError.unsupportedOperation("Cannot shut down simulator in state: \(simulator.state)")
        }
    }

    /// Restarts a simulator.
    public func restartSimulator(udid: String) async throws {
        logger.info("Restarting simulator: \(udid)")
        
        try await shutdownSimulator(udid: udid)
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        try await bootSimulator(udid: udid)
        
        logger.info("Successfully restarted simulator: \(udid)")
    }

    /// Resets a simulator to a clean state.
    public func resetSimulator(udid: String) async throws {
        logger.info("Resetting simulator: \(udid)")
        
        try await ensureShutdown(udid: udid)
        try await eraseSimulator(udid: udid)
        try await bootSimulator(udid: udid)
        
        logger.info("Successfully reset simulator: \(udid)")
    }
}
