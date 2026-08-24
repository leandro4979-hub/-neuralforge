import SwiftUI
import Core

/// A view for editing device profiles.
public struct DeviceProfileEditor: View {
    @Binding public var profile: DeviceProfile
    @State private var name: String
    @State private var deviceType: String
    @State private var screenWidth: String
    @State private var screenHeight: String
    @State private var safeAreaTop: String
    @State private var safeAreaLeading: String
    @State private var safeAreaBottom: String
    @State private var safeAreaTrailing: String
    @State private var orientation: DeviceProfile.DeviceOrientation
    @State private var iOSVersion: String
    @State private var appearance: DeviceProfile.Appearance
    @State private var dynamicType: DeviceProfile.DynamicTypeSize
    @State private var displayScale: String
    @State private var localeIdentifier: String
    @State private var timezoneIdentifier: String
    @State private var uses24HourTime: Bool
    @State private var keyboardVisibility: DeviceProfile.KeyboardVisibility
    @State private var keyboardType: DeviceProfile.KeyboardType
    @State private var batteryPercentage: String
    @State private var isCharging: Bool
    @State private var isLowPowerMode: Bool
    @State private var thermalState: DeviceProfile.ThermalState
    @State private var storageAvailability: DeviceProfile.StorageAvailability
    @State private var memoryPressure: DeviceProfile.MemoryPressure

    public init(profile: Binding<DeviceProfile>) {
        self._profile = profile
        self._name = State(initialValue: profile.wrappedValue.name)
        self._deviceType = State(initialValue: profile.wrappedValue.deviceType)
        self._screenWidth = State(initialValue: String(Int(profile.wrappedValue.screenSize.width)))
        self._screenHeight = State(initialValue: String(Int(profile.wrappedValue.screenSize.height)))
        self._safeAreaTop = State(initialValue: String(Int(profile.wrappedValue.safeAreaInsets.top)))
        self._safeAreaLeading = State(initialValue: String(Int(profile.wrappedValue.safeAreaInsets.leading)))
        self._safeAreaBottom = State(initialValue: String(Int(profile.wrappedValue.safeAreaInsets.bottom)))
        self._safeAreaTrailing = State(initialValue: String(Int(profile.wrappedValue.safeAreaInsets.trailing)))
        self._orientation = State(initialValue: profile.wrappedValue.orientation)
        self._iOSVersion = State(initialValue: profile.wrappedValue.iOSVersion)
        self._appearance = State(initialValue: profile.wrappedValue.appearance)
        self._dynamicType = State(initialValue: profile.wrappedValue.dynamicType)
        self._displayScale = State(initialValue: String(profile.wrappedValue.displayScale))
        self._localeIdentifier = State(initialValue: profile.wrappedValue.locale.identifier)
        self._timezoneIdentifier = State(initialValue: profile.wrappedValue.timezone.identifier)
        self._uses24HourTime = State(initialValue: profile.wrappedValue.uses24HourTime)
        self._keyboardVisibility = State(initialValue: profile.wrappedValue.keyboardVisibility)
        self._keyboardType = State(initialValue: profile.wrappedValue.keyboardType)
        self._batteryPercentage = State(initialValue: String(profile.wrappedValue.batteryPercentage))
        self._isCharging = State(initialValue: profile.wrappedValue.isCharging)
        self._isLowPowerMode = State(initialValue: profile.wrappedValue.isLowPowerMode)
        self._thermalState = State(initialValue: profile.wrappedValue.thermalState)
        self._storageAvailability = State(initialValue: profile.wrappedValue.storageAvailability)
        self._memoryPressure = State(initialValue: profile.wrappedValue.memoryPressure)
    }

    public var body: some View {
        Form {
            Section("General") {
                TextField("Name", text: $name)
                TextField("Device Type", text: $deviceType)
                TextField("iOS Version", text: $iOSVersion)
            }

            Section("Screen") {
                HStack {
                    TextField("Width", text: $screenWidth)
                        .frame(width: 100)
                    TextField("Height", text: $screenHeight)
                        .frame(width: 100)
                }
                HStack {
                    TextField("Safe Area Top", text: $safeAreaTop)
                        .frame(width: 100)
                    TextField("Safe Area Bottom", text: $safeAreaBottom)
                        .frame(width: 100)
                }
                HStack {
                    TextField("Safe Area Leading", text: $safeAreaLeading)
                        .frame(width: 100)
                    TextField("Safe Area Trailing", text: $safeAreaTrailing)
                        .frame(width: 100)
                }
                TextField("Display Scale", text: $displayScale)
            }

            Section("Appearance") {
                Picker("Orientation", selection: $orientation) {
                    ForEach(DeviceProfile.DeviceOrientation.allCases, id: \.self) { orientation in
                        Text(orientation.rawValue)
                            .tag(orientation)
                    }
                }
                Picker("Appearance", selection: $appearance) {
                    ForEach(DeviceProfile.Appearance.allCases, id: \.self) { appearance in
                        Text(appearance.rawValue)
                            .tag(appearance)
                    }
                }
                Picker("Dynamic Type", selection: $dynamicType) {
                    ForEach(DeviceProfile.DynamicTypeSize.allCases, id: \.self) { size in
                        Text(size.rawValue)
                            .tag(size)
                    }
                }
            }

            Section("Localization") {
                TextField("Locale", text: $localeIdentifier)
                TextField("Timezone", text: $timezoneIdentifier)
                Toggle("24-Hour Time", isOn: $uses24HourTime)
            }

            Section("Input") {
                Picker("Keyboard Visibility", selection: $keyboardVisibility) {
                    ForEach(DeviceProfile.KeyboardVisibility.allCases, id: \.self) { visibility in
                        Text(visibility.rawValue)
                            .tag(visibility)
                    }
                }
                Picker("Keyboard Type", selection: $keyboardType) {
                    ForEach(DeviceProfile.KeyboardType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
            }

            Section("Device State") {
                HStack {
                    TextField("Battery %", text: $batteryPercentage)
                        .frame(width: 100)
                    Toggle("Charging", isOn: $isCharging)
                }
                Toggle("Low Power Mode", isOn: $isLowPowerMode)
                Picker("Thermal State", selection: $thermalState) {
                    ForEach(DeviceProfile.ThermalState.allCases, id: \.self) { state in
                        Text(state.rawValue)
                            .tag(state)
                    }
                }
                Picker("Storage Availability", selection: $storageAvailability) {
                    ForEach(DeviceProfile.StorageAvailability.allCases, id: \.self) { availability in
                        Text(availability.rawValue)
                            .tag(availability)
                    }
                }
                Picker("Memory Pressure", selection: $memoryPressure) {
                    ForEach(DeviceProfile.MemoryPressure.allCases, id: \.self) { pressure in
                        Text(pressure.rawValue)
                            .tag(pressure)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onChange(of: name) { newValue in profile.name = newValue }
        .onChange(of: deviceType) { newValue in profile.deviceType = newValue }
        .onChange(of: screenWidth) { newValue in
            if let width = Int(newValue) {
                profile.screenSize.width = CGFloat(width)
            }
        }
        .onChange(of: screenHeight) { newValue in
            if let height = Int(newValue) {
                profile.screenSize.height = CGFloat(height)
            }
        }
        .onChange(of: safeAreaTop) { newValue in
            if let top = Int(newValue) {
                profile.safeAreaInsets.top = CGFloat(top)
            }
        }
        .onChange(of: safeAreaLeading) { newValue in
            if let leading = Int(newValue) {
                profile.safeAreaInsets.leading = CGFloat(leading)
            }
        }
        .onChange(of: safeAreaBottom) { newValue in
            if let bottom = Int(newValue) {
                profile.safeAreaInsets.bottom = CGFloat(bottom)
            }
        }
        .onChange(of: safeAreaTrailing) { newValue in
            if let trailing = Int(newValue) {
                profile.safeAreaInsets.trailing = CGFloat(trailing)
            }
        }
        .onChange(of: orientation) { newValue in profile.orientation = newValue }
        .onChange(of: iOSVersion) { newValue in profile.iOSVersion = newValue }
        .onChange(of: appearance) { newValue in profile.appearance = newValue }
        .onChange(of: dynamicType) { newValue in profile.dynamicType = newValue }
        .onChange(of: displayScale) { newValue in
            if let scale = Double(newValue) {
                profile.displayScale = CGFloat(scale)
            }
        }
        .onChange(of: localeIdentifier) { newValue in
            profile.locale = Locale(identifier: newValue)
        }
        .onChange(of: timezoneIdentifier) { newValue in
            if let timezone = TimeZone(identifier: newValue) {
                profile.timezone = timezone
            }
        }
        .onChange(of: uses24HourTime) { newValue in profile.uses24HourTime = newValue }
        .onChange(of: keyboardVisibility) { newValue in profile.keyboardVisibility = newValue }
        .onChange(of: keyboardType) { newValue in profile.keyboardType = newValue }
        .onChange(of: batteryPercentage) { newValue in
            if let percentage = Int(newValue) {
                profile.batteryPercentage = percentage
            }
        }
        .onChange(of: isCharging) { newValue in profile.isCharging = newValue }
        .onChange(of: isLowPowerMode) { newValue in profile.isLowPowerMode = newValue }
        .onChange(of: thermalState) { newValue in profile.thermalState = newValue }
        .onChange(of: storageAvailability) { newValue in profile.storageAvailability = newValue }
        .onChange(of: memoryPressure) { newValue in profile.memoryPressure = newValue }
    }
}

#Preview {
    @State var profile = DeviceProfile.iPhone15
    return DeviceProfileEditor(profile: $profile)
}
