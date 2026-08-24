import Foundation

/// Information about a discovered iOS simulator.
public struct SimulatorInfo: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let udid: String
    public let name: String
    public let deviceType: String
    public let runtime: String
    public let state: SimulatorState
    public let isAvailable: Bool

    public init(
        id: UUID = UUID(),
        udid: String,
        name: String,
        deviceType: String,
        runtime: String,
        state: SimulatorState,
        isAvailable: Bool
    ) {
        self.id = id
        self.udid = udid
        self.name = name
        self.deviceType = deviceType
        self.runtime = runtime
        self.state = state
        self.isAvailable = isAvailable
    }

    public enum SimulatorState: String, Codable, Equatable {
        case unknown
        case creating
        case shutdown
        case notInstalled
        case booting
        case booted
        case shuttingDown
        case shutdown
    }
}
