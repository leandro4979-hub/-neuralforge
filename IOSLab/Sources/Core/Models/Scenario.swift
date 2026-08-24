import Foundation

/// A test scenario for simulating iOS app behavior.
public struct Scenario: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var description: String
    public var deviceProfileID: UUID?
    public var appLaunchArguments: [String]
    public var environmentVariables: [String: String]
    public var networkProfile: NetworkProfile
    public var permissionConfiguration: PermissionConfiguration
    public var actions: [ScenarioAction]
    public var assertions: [ScenarioAssertion]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String = "Untitled Scenario",
        description: String = "",
        deviceProfileID: UUID? = nil,
        appLaunchArguments: [String] = [],
        environmentVariables: [String: String] = [:],
        networkProfile: NetworkProfile = .default,
        permissionConfiguration: PermissionConfiguration = .default,
        actions: [ScenarioAction] = [],
        assertions: [ScenarioAssertion] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.deviceProfileID = deviceProfileID
        self.appLaunchArguments = appLaunchArguments
        self.environmentVariables = environmentVariables
        self.networkProfile = networkProfile
        self.permissionConfiguration = permissionConfiguration
        self.actions = actions
        self.assertions = assertions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Nested Models
    public struct NetworkProfile: Codable, Equatable {
        public var profileType: NetworkProfileType
        public var latency: TimeInterval?
        public var packetLoss: Double?
        public var jitter: TimeInterval?
        public var downloadSpeed: Int?
        public var uploadSpeed: Int?
        public var isIntermittent: Bool
        public var captivePortalBehavior: CaptivePortalBehavior?

        public init(
            profileType: NetworkProfileType = .wifi,
            latency: TimeInterval? = nil,
            packetLoss: Double? = nil,
            jitter: TimeInterval? = nil,
            downloadSpeed: Int? = nil,
            uploadSpeed: Int? = nil,
            isIntermittent: Bool = false,
            captivePortalBehavior: CaptivePortalBehavior? = nil
        ) {
            self.profileType = profileType
            self.latency = latency
            self.packetLoss = packetLoss
            self.jitter = jitter
            self.downloadSpeed = downloadSpeed
            self.uploadSpeed = uploadSpeed
            self.isIntermittent = isIntermittent
            self.captivePortalBehavior = captivePortalBehavior
        }

        public enum NetworkProfileType: String, Codable, Equatable, CaseIterable {
            case offline
            case wifi
            case cellular3G
            case cellular4G
            case cellular5G
            case custom
        }

        public enum CaptivePortalBehavior: String, Codable, Equatable, CaseIterable {
            case none
            case redirectToLogin
            case blockAll
        }

        public static let `default` = NetworkProfile()
        public static let offline = NetworkProfile(profileType: .offline)
        public static let wifi = NetworkProfile(profileType: .wifi)
        public static let cellular3G = NetworkProfile(profileType: .cellular3G)
        public static let cellular4G = NetworkProfile(profileType: .cellular4G)
        public static let cellular5G = NetworkProfile(profileType: .cellular5G)
    }

    public struct PermissionConfiguration: Codable, Equatable {
        public var camera: PermissionState
        public var photos: PermissionState
        public var microphone: PermissionState
        public var location: PermissionState
        public var bluetooth: PermissionState
        public var contacts: PermissionState
        public var notifications: PermissionState
        public var tracking: PermissionState

        public init(
            camera: PermissionState = .notDetermined,
            photos: PermissionState = .notDetermined,
            microphone: PermissionState = .notDetermined,
            location: PermissionState = .notDetermined,
            bluetooth: PermissionState = .notDetermined,
            contacts: PermissionState = .notDetermined,
            notifications: PermissionState = .notDetermined,
            tracking: PermissionState = .notDetermined
        ) {
            self.camera = camera
            self.photos = photos
            self.microphone = microphone
            self.location = location
            self.bluetooth = bluetooth
            self.contacts = contacts
            self.notifications = notifications
            self.tracking = tracking
        }

        public enum PermissionState: String, Codable, Equatable, CaseIterable {
            case notDetermined
            case granted
            case denied
            case limited
        }

        public static let `default` = PermissionConfiguration()
    }
}

// MARK: - Scenario Actions
public enum ScenarioAction: Codable, Equatable, Identifiable {
    case launchApp(bundleID: String)
    case tapElement(accessibilityIdentifier: String)
    case enterText(text: String, accessibilityIdentifier: String)
    case swipe(direction: SwipeDirection, accessibilityIdentifier: String?)
    case rotateDevice(orientation: DeviceProfile.DeviceOrientation)
    case changeNetworkProfile(profile: Scenario.NetworkProfile)
    case sendToBackground
    case sendToForeground
    case injectPushNotification(payload: PushNotificationPayload)
    case simulateLocationUpdate(latitude: Double, longitude: Double)
    case captureScreenshot(name: String?)
    case delay(duration: TimeInterval)
    case custom(command: String)

    public var id: UUID {
        switch self {
        case .launchApp: return UUID()
        case .tapElement: return UUID()
        case .enterText: return UUID()
        case .swipe: return UUID()
        case .rotateDevice: return UUID()
        case .changeNetworkProfile: return UUID()
        case .sendToBackground: return UUID()
        case .sendToForeground: return UUID()
        case .injectPushNotification: return UUID()
        case .simulateLocationUpdate: return UUID()
        case .captureScreenshot: return UUID()
        case .delay: return UUID()
        case .custom: return UUID()
        }
    }

    public enum SwipeDirection: String, Codable, Equatable {
        case up
        case down
        case left
        case right
    }

    public struct PushNotificationPayload: Codable, Equatable {
        public var title: String
        public var body: String
        public var data: [String: String]

        public init(title: String, body: String, data: [String: String] = [:]) {
            self.title = title
            self.body = body
            self.data = data
        }
    }
}

// MARK: - Scenario Assertions
public enum ScenarioAssertion: Codable, Equatable, Identifiable {
    case assertVisibleText(text: String)
    case assertAccessibilityLabel(label: String)
    case assertElementExists(accessibilityIdentifier: String)
    case assertElementDoesNotExist(accessibilityIdentifier: String)
    case assertNavigationState(route: String)
    case assertAPIRequestData(endpoint: String, expectedData: [String: Any])
    case assertScreenshotMatchesBaseline(name: String)
    case assertTrue(expression: String)
    case assertFalse(expression: String)

    public var id: UUID {
        switch self {
        case .assertVisibleText: return UUID()
        case .assertAccessibilityLabel: return UUID()
        case .assertElementExists: return UUID()
        case .assertElementDoesNotExist: return UUID()
        case .assertNavigationState: return UUID()
        case .assertAPIRequestData: return UUID()
        case .assertScreenshotMatchesBaseline: return UUID()
        case .assertTrue: return UUID()
        case .assertFalse: return UUID()
        }
    }
}
