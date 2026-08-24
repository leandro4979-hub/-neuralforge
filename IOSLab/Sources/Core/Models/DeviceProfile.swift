import Foundation
import SwiftUI

/// A configurable device profile for simulating iPhone conditions.
public struct DeviceProfile: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var deviceType: String
    public var screenSize: CGSize
    public var safeAreaInsets: EdgeInsets
    public var orientation: DeviceOrientation
    public var iOSVersion: String
    public var appearance: Appearance
    public var dynamicType: DynamicTypeSize
    public var displayScale: CGFloat
    public var locale: Locale
    public var timezone: TimeZone
    public var uses24HourTime: Bool
    public var keyboardVisibility: KeyboardVisibility
    public var keyboardType: KeyboardType
    public var batteryPercentage: Int
    public var isCharging: Bool
    public var isLowPowerMode: Bool
    public var thermalState: ThermalState
    public var storageAvailability: StorageAvailability
    public var memoryPressure: MemoryPressure

    public init(
        id: UUID = UUID(),
        name: String = "Custom Profile",
        deviceType: String = "iPhone 15",
        screenSize: CGSize = CGSize(width: 390, height: 844),
        safeAreaInsets: EdgeInsets = EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0),
        orientation: DeviceOrientation = .portrait,
        iOSVersion: String = "17.0",
        appearance: Appearance = .system,
        dynamicType: DynamicTypeSize = .medium,
        displayScale: CGFloat = 3.0,
        locale: Locale = Locale(identifier: "en_US"),
        timezone: TimeZone = TimeZone(identifier: "America/New_York")!,
        uses24HourTime: Bool = false,
        keyboardVisibility: KeyboardVisibility = .hidden,
        keyboardType: KeyboardType = .default,
        batteryPercentage: Int = 100,
        isCharging: Bool = true,
        isLowPowerMode: Bool = false,
        thermalState: ThermalState = .normal,
        storageAvailability: StorageAvailability = .normal,
        memoryPressure: MemoryPressure = .normal
    ) {
        self.id = id
        self.name = name
        self.deviceType = deviceType
        self.screenSize = screenSize
        self.safeAreaInsets = safeAreaInsets
        self.orientation = orientation
        self.iOSVersion = iOSVersion
        self.appearance = appearance
        self.dynamicType = dynamicType
        self.displayScale = displayScale
        self.locale = locale
        self.timezone = timezone
        self.uses24HourTime = uses24HourTime
        self.keyboardVisibility = keyboardVisibility
        self.keyboardType = keyboardType
        self.batteryPercentage = batteryPercentage
        self.isCharging = isCharging
        self.isLowPowerMode = isLowPowerMode
        self.thermalState = thermalState
        self.storageAvailability = storageAvailability
        self.memoryPressure = memoryPressure
    }

    // MARK: - Enums
    public enum DeviceOrientation: String, Codable, Equatable, CaseIterable {
        case portrait
        case landscapeLeft
        case landscapeRight
        case portraitUpsideDown
    }

    public enum Appearance: String, Codable, Equatable, CaseIterable {
        case light
        case dark
        case system
    }

    public enum DynamicTypeSize: String, Codable, Equatable, CaseIterable {
        case xSmall = "XS"
        case small = "S"
        case medium = "M"
        case large = "L"
        case xLarge = "XL"
        case xxLarge = "XXL"
        case xxxLarge = "XXXL"
        case accessibility1 = "A1"
        case accessibility2 = "A2"
        case accessibility3 = "A3"
        case accessibility4 = "A4"
        case accessibility5 = "A5"
    }

    public enum KeyboardVisibility: String, Codable, Equatable, CaseIterable {
        case hidden
        case visible
    }

    public enum KeyboardType: String, Codable, Equatable, CaseIterable {
        case `default`
        case asciiCapable
        case numbersAndPunctuation
        case URL
        case numberPad
        case phonePad
        case namePhonePad
        case emailAddress
        case decimalPad
        case twitter
        case webSearch
    }

    public enum ThermalState: String, Codable, Equatable, CaseIterable {
        case normal
        case warm
        case critical
    }

    public enum StorageAvailability: String, Codable, Equatable, CaseIterable {
        case normal
        case low
        case critical
    }

    public enum MemoryPressure: String, Codable, Equatable, CaseIterable {
        case normal
        case warning
        case critical
    }

    // MARK: - Presets
    public static let iPhone15: DeviceProfile = {
        var profile = DeviceProfile()
        profile.name = "iPhone 15"
        profile.deviceType = "iPhone 15"
        profile.screenSize = CGSize(width: 390, height: 844)
        profile.safeAreaInsets = EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0)
        profile.iOSVersion = "17.0"
        profile.displayScale = 3.0
        return profile
    }()

    public static let iPhone15Plus: DeviceProfile = {
        var profile = DeviceProfile()
        profile.name = "iPhone 15 Plus"
        profile.deviceType = "iPhone 15 Plus"
        profile.screenSize = CGSize(width: 428, height: 926)
        profile.safeAreaInsets = EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0)
        profile.iOSVersion = "17.0"
        profile.displayScale = 3.0
        return profile
    }()

    public static let iPhone15Pro: DeviceProfile = {
        var profile = DeviceProfile()
        profile.name = "iPhone 15 Pro"
        profile.deviceType = "iPhone 15 Pro"
        profile.screenSize = CGSize(width: 390, height: 844)
        profile.safeAreaInsets = EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0)
        profile.iOSVersion = "17.0"
        profile.displayScale = 3.0
        return profile
    }()

    public static let iPhone15ProMax: DeviceProfile = {
        var profile = DeviceProfile()
        profile.name = "iPhone 15 Pro Max"
        profile.deviceType = "iPhone 15 Pro Max"
        profile.screenSize = CGSize(width: 428, height: 926)
        profile.safeAreaInsets = EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0)
        profile.iOSVersion = "17.0"
        profile.displayScale = 3.0
        return profile
    }()

    public static let iPadPro12_9: DeviceProfile = {
        var profile = DeviceProfile()
        profile.name = "iPad Pro (12.9-inch)"
        profile.deviceType = "iPad Pro (12.9-inch)"
        profile.screenSize = CGSize(width: 1024, height: 1366)
        profile.safeAreaInsets = EdgeInsets(top: 24, leading: 0, bottom: 20, trailing: 0)
        profile.iOSVersion = "17.0"
        profile.displayScale = 2.0
        return profile
    }()

    public static let allPresets: [DeviceProfile] = [
        .iPhone15,
        .iPhone15Plus,
        .iPhone15Pro,
        .iPhone15ProMax,
        .iPadPro12_9
    ]
}

// MARK: - EdgeInsets (Codable)
extension EdgeInsets: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let top = try container.decode(CGFloat.self, forKey: .top)
        let leading = try container.decode(CGFloat.self, forKey: .leading)
        let bottom = try container.decode(CGFloat.self, forKey: .bottom)
        let trailing = try container.decode(CGFloat.self, forKey: .trailing)
        self.init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(top, forKey: .top)
        try container.encode(leading, forKey: .leading)
        try container.encode(bottom, forKey: .bottom)
        try container.encode(trailing, forKey: .trailing)
    }

    private enum CodingKeys: CodingKey {
        case top
        case leading
        case bottom
        case trailing
    }
}
