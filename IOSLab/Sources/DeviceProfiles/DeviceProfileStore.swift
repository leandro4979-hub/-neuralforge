import Foundation
import Core

/// Manages storage and retrieval of device profiles.
public final class DeviceProfileStore: ObservableObject {
    @Published public private(set) var profiles: [DeviceProfile] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: IOSLabError?

    private let logger: Logger
    private let profilesURL: URL

    public init(logger: Logger, profilesURL: URL? = nil) {
        self.logger = logger
        self.profilesURL = profilesURL ?? defaultProfilesURL
        loadProfiles()
    }

    // MARK: - Default Profiles URL
    private static var defaultProfilesURL: URL {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let iosLabURL = appSupportURL.appendingPathComponent("IOSLab", isDirectory: true)
        try? fileManager.createDirectory(at: iosLabURL, withIntermediateDirectories: true)
        return iosLabURL.appendingPathComponent("DeviceProfiles.json", isDirectory: false)
    }

    // MARK: - Load Profiles
    public func loadProfiles() {
        isLoading = true
        error = nil

        do {
            if FileManager.default.fileExists(atPath: profilesURL.path) {
                let data = try Data(contentsOf: profilesURL)
                let decoder = JSONDecoder()
                profiles = try decoder.decode([DeviceProfile].self, from: data)
            } else {
                // Load default profiles
                profiles = DeviceProfile.allPresets
                try saveProfiles()
            }
        } catch {
            logger.error("Failed to load profiles: \(error)")
            self.error = IOSLabError.internalError(error.localizedDescription)
            profiles = DeviceProfile.allPresets
        }

        isLoading = false
    }

    // MARK: - Save Profiles
    public func saveProfiles() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(profiles)
        try data.write(to: profilesURL, options: [.atomic])
    }

    // MARK: - Add Profile
    public func addProfile(_ profile: DeviceProfile) throws {
        guard !profiles.contains(where: { $0.id == profile.id }) else {
            throw IOSLabError.duplicateScenarioName(profile.name)
        }
        profiles.append(profile)
        try saveProfiles()
    }

    // MARK: - Update Profile
    public func updateProfile(_ profile: DeviceProfile) throws {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            throw IOSLabError.invalidDeviceProfile("Profile not found")
        }
        profiles[index] = profile
        try saveProfiles()
    }

    // MARK: - Delete Profile
    public func deleteProfile(_ profile: DeviceProfile) throws {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else {
            throw IOSLabError.invalidDeviceProfile("Profile not found")
        }
        profiles.remove(at: index)
        try saveProfiles()
    }

    // MARK: - Get Profile by ID
    public func profile(withID id: UUID) -> DeviceProfile? {
        profiles.first { $0.id == id }
    }

    // MARK: - Import Profiles
    public func importProfiles(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let importedProfiles = try decoder.decode([DeviceProfile].self, from: data)

        // Check for duplicates
        for profile in importedProfiles {
            if profiles.contains(where: { $0.name == profile.name }) {
                throw IOSLabError.duplicateScenarioName(profile.name)
            }
        }

        profiles.append(contentsOf: importedProfiles)
        try saveProfiles()
    }

    // MARK: - Export Profiles
    public func exportProfiles(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(profiles)
        try data.write(to: url, options: [.atomic])
    }
}
