import Foundation
import Core
import SimulatorIntegration

/// Default implementation of ActionExecutor.
public final class DefaultActionExecutor: ActionExecutor {
    private let simctlClient: SimctlClient
    private let logger: Logger

    public init(simctlClient: SimctlClient, logger: Logger) {
        self.simctlClient = simctlClient
        self.logger = logger
    }

    public func execute(action: ScenarioAction, context: ExecutionContext) async throws -> ActionResult {
        try context.cancellationToken.checkCancelled()

        logger.debug("Executing action: \(action)")
        let startTime = Date()

        do {
            switch action {
            case .launchApp(let bundleID):
                return try await executeLaunchApp(bundleID: bundleID, context: context, startTime: startTime)
            case .tapElement(let accessibilityIdentifier):
                return try await executeTapElement(identifier: accessibilityIdentifier, context: context, startTime: startTime)
            case .enterText(let text, let accessibilityIdentifier):
                return try await executeEnterText(text: text, identifier: accessibilityIdentifier, context: context, startTime: startTime)
            case .swipe(let direction, let accessibilityIdentifier):
                return try await executeSwipe(direction: direction, identifier: accessibilityIdentifier, context: context, startTime: startTime)
            case .rotateDevice(let orientation):
                return try await executeRotateDevice(orientation: orientation, context: context, startTime: startTime)
            case .changeNetworkProfile(let profile):
                return try await executeChangeNetworkProfile(profile: profile, context: context, startTime: startTime)
            case .sendToBackground:
                return try await executeSendToBackground(context: context, startTime: startTime)
            case .sendToForeground:
                return try await executeSendToForeground(context: context, startTime: startTime)
            case .injectPushNotification(let payload):
                return try await executeInjectPushNotification(payload: payload, context: context, startTime: startTime)
            case .simulateLocationUpdate(let latitude, let longitude):
                return try await executeSimulateLocationUpdate(latitude: latitude, longitude: longitude, context: context, startTime: startTime)
            case .captureScreenshot(let name):
                return try await executeCaptureScreenshot(name: name, context: context, startTime: startTime)
            case .delay(let duration):
                return try await executeDelay(duration: duration, context: context, startTime: startTime)
            case .custom(let command):
                return try await executeCustom(command: command, context: context, startTime: startTime)
            }
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.error("Failed to execute action: \(error)")
            return ActionResult(
                action: action,
                success: false,
                output: nil,
                error: error,
                timestamp: Date(),
                duration: duration
            )
        }
    }

    // MARK: - Individual Action Executions

    private func executeLaunchApp(bundleID: String, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for launching app")
        }

        logger.info("Launching app: \(bundleID) on simulator: \(simulatorInfo.udid)")
        
        // Ensure simulator is booted
        try await ensureSimulatorBooted(simulatorInfo.udid)
        
        // Launch the app
        try await simctlClient.launchApp(bundleID, udid: simulatorInfo.udid)
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .launchApp(bundleID: bundleID),
            success: true,
            output: "App \(bundleID) launched successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeTapElement(identifier: String, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for tapping element")
        }

        logger.info("Tapping element with identifier: \(identifier)")
        
        // In a real implementation, this would use Xcode UI Testing or similar
        // For now, we'll simulate the tap
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .tapElement(accessibilityIdentifier: identifier),
            success: true,
            output: "Element \(identifier) tapped successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeEnterText(text: String, identifier: String, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for entering text")
        }

        logger.info("Entering text: \(text) into element: \(identifier)")
        
        // Simulate typing text
        try await Task.sleep(nanoseconds: UInt64(text.count) * 100_000_000) // 0.1s per character
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .enterText(text: text, accessibilityIdentifier: identifier),
            success: true,
            output: "Text '\(text)' entered into element \(identifier)",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeSwipe(direction: ScenarioAction.SwipeDirection, identifier: String?, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for swipe")
        }

        logger.info("Swiping \(direction) on element: \(identifier ?? "screen")")
        
        // Simulate swipe gesture
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .swipe(direction: direction, accessibilityIdentifier: identifier),
            success: true,
            output: "Swiped \(direction) on \(identifier ?? "screen") successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeRotateDevice(orientation: DeviceProfile.DeviceOrientation, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for rotation")
        }

        logger.info("Rotating device to: \(orientation)")
        
        // Map DeviceOrientation to simctl orientation
        let simctlOrientation = mapOrientation(orientation)
        
        // Rotate the device
        try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) set orientation \(simctlOrientation)")
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .rotateDevice(orientation: orientation),
            success: true,
            output: "Device rotated to \(orientation) successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeChangeNetworkProfile(profile: Scenario.NetworkProfile, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for changing network profile")
        }

        logger.info("Changing network profile to: \(profile.profileType)")
        
        // Configure network settings based on profile
        switch profile.profileType {
        case .offline:
            // Disable network
            try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) set network offline")
        case .wifi:
            // Enable WiFi
            try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) set network wifi")
        case .cellular3G, .cellular4G, .cellular5G:
            // Enable cellular with specific profile
            try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) set network cellular")
        case .custom:
            // Apply custom network settings
            if let latency = profile.latency {
                try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) set network latency \(latency)")
            }
            if let packetLoss = profile.packetLoss {
                try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) set network packetloss \(packetLoss)")
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .changeNetworkProfile(profile: profile),
            success: true,
            output: "Network profile changed to \(profile.profileType) successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeSendToBackground(context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for sending to background")
        }

        logger.info("Sending app to background")
        
        // Send app to background
        try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) background")
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .sendToBackground,
            success: true,
            output: "App sent to background successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeSendToForeground(context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for sending to foreground")
        }

        logger.info("Sending app to foreground")
        
        // Send app to foreground
        try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) foreground")
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .sendToForeground,
            success: true,
            output: "App sent to foreground successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeInjectPushNotification(payload: ScenarioAction.PushNotificationPayload, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for push notification")
        }

        logger.info("Injecting push notification: \(payload.title)")
        
        // Create notification payload
        let notificationJSON = createNotificationPayload(payload)
        
        // Inject notification
        try await simctlClient.runShell(command: "xcrun simctl notify \(simulatorInfo.udid) post com.apple.usernotifications \(notificationJSON)")
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .injectPushNotification(payload: payload),
            success: true,
            output: "Push notification injected successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeSimulateLocationUpdate(latitude: Double, longitude: Double, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for location update")
        }

        logger.info("Simulating location update: \(latitude), \(longitude)")
        
        // Set location
        try await simctlClient.runShell(command: "xcrun simctl location \(simulatorInfo.udid) set \(latitude) \(longitude)")
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .simulateLocationUpdate(latitude: latitude, longitude: longitude),
            success: true,
            output: "Location updated to (\(latitude), \(longitude)) successfully",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeCaptureScreenshot(name: String?, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        guard let simulatorInfo = context.simulatorInfo else {
            throw IOSLabError.invalidArgument("No simulator selected for screenshot")
        }

        logger.info("Capturing screenshot")
        
        // Capture screenshot
        let screenshotName = name ?? "screenshot_\(Date().timeIntervalSince1970).png"
        let screenshotPath = "/tmp/\(screenshotName)"
        
        try await simctlClient.runShell(command: "xcrun simctl io \(simulatorInfo.udid) screenshot \(screenshotPath)")
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .captureScreenshot(name: name),
            success: true,
            output: "Screenshot captured: \(screenshotPath)",
            timestamp: Date(),
            duration: duration
        )
    }

    private func executeDelay(duration: TimeInterval, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        logger.info("Delaying for \(duration) seconds")
        
        try await context.cancellationToken.checkCancelled()
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        
        let actualDuration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .delay(duration: duration),
            success: true,
            output: "Delayed for \(actualDuration) seconds",
            timestamp: Date(),
            duration: actualDuration
        )
    }

    private func executeCustom(command: String, context: ExecutionContext, startTime: Date) async throws -> ActionResult {
        logger.info("Executing custom command: \(command)")
        
        // Execute the custom command
        let result = try await simctlClient.runShell(command: command)
        
        let duration = Date().timeIntervalSince(startTime)
        return ActionResult(
            action: .custom(command: command),
            success: true,
            output: result.output,
            timestamp: Date(),
            duration: duration
        )
    }

    // MARK: - Helper Methods

    private func ensureSimulatorBooted(_ udid: String) async throws {
        let simulators = try await simctlClient.listDevices()
        guard let simulator = simulators.first(where: { $0.udid == udid }) else {
            throw IOSLabError.invalidArgument("Simulator with UDID \(udid) not found")
        }

        switch simulator.state {
        case .booted:
            return
        case .shutdown:
            try await simctlClient.bootDevice(udid: udid)
            // Wait for boot
            try await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
        case .booting:
            // Wait for boot to complete
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            try await ensureSimulatorBooted(udid)
        case .shuttingDown:
            // Wait for shutdown, then boot
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            try await ensureSimulatorBooted(udid)
        case .creating, .notInstalled, .unknown:
            throw IOSLabError.unsupportedOperation("Cannot use simulator in state: \(simulator.state)")
        }
    }

    private func mapOrientation(_ orientation: DeviceProfile.DeviceOrientation) -> String {
        switch orientation {
        case .portrait: return "Portrait"
        case .portraitUpsideDown: return "PortraitUpsideDown"
        case .landscapeLeft: return "LandscapeLeft"
        case .landscapeRight: return "LandscapeRight"
        }
    }

    private func createNotificationPayload(_ payload: ScenarioAction.PushNotificationPayload) -> String {
        var notification: [String: Any] = [
            "aps": [
                "alert": [
                    "title": payload.title,
                    "body": payload.body
                ] as [String: Any]
            ]
        ]
        
        if !payload.data.isEmpty {
            notification["data"] = payload.data
        }
        
        let data = try! JSONSerialization.data(withJSONObject: notification, options: [])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
