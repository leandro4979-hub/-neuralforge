import SwiftUI
import Core
import ScenarioEngine

/// View for executing and monitoring a scenario.
public struct ScenarioExecutionView: View {
    @EnvironmentObject private var container: DependencyContainer
    @Environment(\dismiss) private var dismiss
    
    @StateObject private var runner: ScenarioRunner
    @State private var executionTask: Task<ExecutionResult, Error>?
    @State private var executionResult: ExecutionResult?
    @State private var showTimeline = false

    public let scenario: Scenario
    public let deviceProfile: DeviceProfile?
    public let simulatorInfo: SimulatorInfo?

    public init(scenario: Scenario, deviceProfile: DeviceProfile? = nil, simulatorInfo: SimulatorInfo? = nil) {
        self.scenario = scenario
        self.deviceProfile = deviceProfile
        self.simulatorInfo = simulatorInfo
        
        let actionExecutor = DefaultActionExecutor(
            simctlClient: container.simctlClient,
            logger: container.logger
        )
        let assertionValidator = DefaultAssertionValidator(logger: container.logger)
        
        self._runner = StateObject(wrappedValue: ScenarioRunner(
            actionExecutor: actionExecutor,
            assertionValidator: assertionValidator,
            logger: container.logger,
            deviceProfileStore: container.deviceProfileStore,
            simctlClient: container.simctlClient
        ))
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Scenario info
                ScenarioInfoCard(scenario: scenario, deviceProfile: deviceProfile, simulatorInfo: simulatorInfo)

                // Execution controls
                ExecutionControls(
                    runner: runner,
                    isExecuting: executionTask != nil,
                    onExecute: { startExecution() },
                    onCancel: { cancelExecution() },
                    onPause: { pauseExecution() },
                    onResume: { resumeExecution() }
                )

                // Progress
                if let executionResult = executionResult {
                    ExecutionSummary(result: executionResult)
                } else if runner.state == .running || runner.state == .paused {
                    LiveExecutionProgress(runner: runner)
                } else {
                    EmptyState()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Execute Scenario")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Timeline") {
                        showTimeline = true
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showTimeline) {
                ExecutionTimelineView(runner: runner)
                    .environmentObject(container)
            }
            .onDisappear {
                if executionTask != nil {
                    cancelExecution()
                }
            }
        }
    }

    // MARK: - Execution Control Methods

    private func startExecution() {
        guard executionTask == nil else { return }

        runner.state = .running
        executionResult = nil

        executionTask = Task {
            let simulatorUDID = simulatorInfo?.udid
            let deviceProfileID = deviceProfile?.id
            
            return try await runner.execute(
                scenario: scenario,
                deviceProfileID: deviceProfileID,
                simulatorUDID: simulatorUDID,
                timeout: 300 // 5 minutes timeout
            )
        }

        // Monitor execution
        Task {
            await executionTask?.value
            executionResult = try? await executionTask?.value
            executionTask = nil
        }
    }

    private func cancelExecution() {
        runner.cancel()
        executionTask?.cancel()
        executionTask = nil
    }

    private func pauseExecution() {
        runner.pause()
    }

    private func resumeExecution() {
        runner.resume()
    }
}

/// Card displaying scenario information.
struct ScenarioInfoCard: View {
    let scenario: Scenario
    let deviceProfile: DeviceProfile?
    let simulatorInfo: SimulatorInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(scenario.name)
                .font(.title2)
                .fontWeight(.semibold)

            if !scenario.description.isEmpty {
                Text(scenario.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                if let deviceProfile = deviceProfile {
                    VStack(alignment: .leading) {
                        Text("Device Profile")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(deviceProfile.name)
                            .font(.subheadline)
                    }
                }

                if let simulatorInfo = simulatorInfo {
                    VStack(alignment: .leading) {
                        Text("Simulator")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(simulatorInfo.name)
                            .font(.subheadline)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Actions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(scenario.actions.count)")
                        .font(.subheadline)
                }

                VStack(alignment: .trailing) {
                    Text("Assertions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(scenario.assertions.count)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// Execution control buttons.
struct ExecutionControls: View {
    @ObservedObject var runner: ScenarioRunner
    let isExecuting: Bool
    let onExecute: () -> Void
    let onCancel: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            if runner.state == .running {
                Button(action: onPause) {
                    Label("Pause", systemImage: "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.yellow)

                Button(action: onCancel) {
                    Label("Cancel", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else if runner.state == .paused {
                Button(action: onResume) {
                    Label("Resume", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)

                Button(action: onCancel) {
                    Label("Cancel", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            } else {
                Button(action: onExecute) {
                    Label("Execute", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(isExecuting)
            }
        }
    }
}

/// Live execution progress view.
struct LiveExecutionProgress: View {
    @ObservedObject var runner: ScenarioRunner

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Current action
            if runner.progress.currentActionIndex < runner.progress.totalActions {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Action")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if runner.progress.currentActionIndex < runner.actionResults.count {
                        let action = runner.actionResults[runner.progress.currentActionIndex]
                        Text(actionDescription(for: action.action))
                            .font(.subheadline)
                    } else {
                        Text("Starting...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Current assertion
            if runner.progress.currentAssertionIndex < runner.progress.totalAssertions {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Assertion")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if runner.progress.currentAssertionIndex < runner.assertionResults.count {
                        let assertion = runner.assertionResults[runner.progress.currentAssertionIndex]
                        Text(assertionDescription(for: assertion.assertion))
                            .font(.subheadline)
                    } else {
                        Text("Waiting...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Progress
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ProgressView(value: progressValue, total: 1.0)
                    .tint(.blue)
                
                HStack {
                    Text("Actions: \(runner.progress.currentActionIndex)/\(runner.progress.totalActions)")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("Assertions: \(runner.progress.currentAssertionIndex)/\(runner.progress.totalAssertions)")
                        .font(.caption)
                }
            }

            // Time
            HStack {
                Text("Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(formatTime(runner.progress.elapsedTime))
                    .font(.subheadline)
                    .monospacedDigit()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var progressValue: Double {
        let actionProgress = runner.progress.totalActions > 0 ? 
            Double(runner.progress.currentActionIndex) / Double(runner.progress.totalActions) : 0.0
        let assertionProgress = runner.progress.totalAssertions > 0 ?
            Double(runner.progress.currentAssertionIndex) / Double(runner.progress.totalAssertions) : 0.0
        
        return (actionProgress + assertionProgress) / 2.0
    }

    private func actionDescription(for action: ScenarioAction) -> String {
        switch action {
        case .launchApp(let bundleID): return "Launching \(bundleID)..."
        case .tapElement(let identifier): return "Tapping \(identifier)..."
        case .enterText(let text, let identifier): return "Entering text into \(identifier)..."
        case .swipe(let direction, _): return "Swiping \(direction)..."
        case .rotateDevice(let orientation): return "Rotating to \(orientation)..."
        case .changeNetworkProfile(let profile): return "Changing network to \(profile.profileType)..."
        case .sendToBackground: return "Sending to background..."
        case .sendToForeground: return "Sending to foreground..."
        case .injectPushNotification(let payload): return "Injecting push notification..."
        case .simulateLocationUpdate(let lat, let lon): return "Updating location..."
        case .captureScreenshot(let name): return "Capturing screenshot..."
        case .delay(let duration): return "Waiting \(duration)s..."
        case .custom(let command): return "Executing: \(command)..."
        }
    }

    private func assertionDescription(for assertion: ScenarioAssertion) -> String {
        switch assertion {
        case .assertVisibleText(let text): return "Checking for text: \(text)"
        case .assertAccessibilityLabel(let label): return "Checking label: \(label)"
        case .assertElementExists(let identifier): return "Checking element exists: \(identifier)"
        case .assertElementDoesNotExist(let identifier): return "Checking element does not exist: \(identifier)"
        case .assertNavigationState(let route): return "Checking route: \(route)"
        case .assertAPIRequestData(let endpoint, _): return "Checking API: \(endpoint)"
        case .assertScreenshotMatchesBaseline(let name): return "Checking screenshot: \(name)"
        case .assertTrue(let expression): return "Checking: \(expression)"
        case .assertFalse(let expression): return "Checking: \(expression)"
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0s"
    }
}

/// Execution summary view.
struct ExecutionSummary: View {
    let result: ExecutionResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status
            HStack {
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(result.success ? .green : .red)
                
                Text(result.success ? "Execution Succeeded" : "Execution Failed")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()
            }

            Divider()

            // Summary stats
            HStack {
                StatView(label: "Actions", value: "\(result.actionResults.count)", passed: allActionsSucceeded)
                
                Spacer()
                
                StatView(label: "Assertions", value: "\(result.assertionResults.count)", passed: allAssertionsPassed)
                
                Spacer()
                
                StatView(label: "Time", value: formatTime(result.duration), passed: true)
            }

            // Failed actions
            if !allActionsSucceeded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Failed Actions")
                        .font(.headline)
                    
                    ForEach(result.actionResults.filter { !$0.success }, id: \.id) { result in
                        FailedItemView(
                            index: result.action.id.hashValue,
                            description: actionDescription(for: result.action),
                            error: result.error?.localizedDescription ?? "Unknown error"
                        )
                    }
                }
            }

            // Failed assertions
            if !allAssertionsPassed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Failed Assertions")
                        .font(.headline)
                    
                    ForEach(result.assertionResults.filter { !$0.passed }, id: \.id) { result in
                        FailedItemView(
                            index: result.assertion.id.hashValue,
                            description: assertionDescription(for: result.assertion),
                            error: result.message ?? result.error?.localizedDescription ?? "Unknown error"
                        )
                    }
                }
            }

            // Error
            if let error = result.error {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Error")
                        .font(.headline)
                    
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var allActionsSucceeded: Bool {
        result.actionResults.allSatisfy { $0.success }
    }

    private var allAssertionsPassed: Bool {
        result.assertionResults.allSatisfy { $0.passed }
    }

    private func actionDescription(for action: ScenarioAction) -> String {
        switch action {
        case .launchApp(let bundleID): return "Launch \(bundleID)"
        case .tapElement(let identifier): return "Tap \(identifier)"
        case .enterText(_, let identifier): return "Enter text into \(identifier)"
        case .swipe(let direction, _): return "Swipe \(direction)"
        case .rotateDevice(let orientation): return "Rotate to \(orientation)"
        case .changeNetworkProfile(let profile): return "Change network to \(profile.profileType)"
        case .sendToBackground: return "Send to background"
        case .sendToForeground: return "Send to foreground"
        case .injectPushNotification(let payload): return "Push notification: \(payload.title)"
        case .simulateLocationUpdate(let lat, let lon): return "Location: (\(lat), \(lon))"
        case .captureScreenshot(let name): return "Screenshot: \(name ?? "unnamed")"
        case .delay(let duration): return "Delay: \(duration)s"
        case .custom(let command): return "Custom: \(command)"
        }
    }

    private func assertionDescription(for assertion: ScenarioAssertion) -> String {
        switch assertion {
        case .assertVisibleText(let text): return "Visible text: \(text)"
        case .assertAccessibilityLabel(let label): return "Label: \(label)"
        case .assertElementExists(let identifier): return "Element exists: \(identifier)"
        case .assertElementDoesNotExist(let identifier): return "Element not exists: \(identifier)"
        case .assertNavigationState(let route): return "Route: \(route)"
        case .assertAPIRequestData(let endpoint, _): return "API: \(endpoint)"
        case .assertScreenshotMatchesBaseline(let name): return "Screenshot: \(name)"
        case .assertTrue(let expression): return "True: \(expression)"
        case .assertFalse(let expression): return "False: \(expression)"
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0s"
    }
}

/// Stat view for summary.
struct StatView: View {
    let label: String
    let value: String
    let passed: Bool

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(passed ? .green : .red)
        }
    }
}

/// Failed item view.
struct FailedItemView: View {
    let index: Int
    let description: String
    let error: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(index)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(description)
                    .font(.subheadline)
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(8)
        .background(Color.red.opacity(0.05))
        .cornerRadius(6)
    }
}

/// Empty state view.
struct EmptyState: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "play.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Ready to execute")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap Execute to start the scenario")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview {
    let container = DependencyContainer.preview
    let scenario = Scenario(
        name: "Test Scenario",
        description: "A test scenario for preview",
        actions: [
            .launchApp(bundleID: "com.example.app"),
            .tapElement(accessibilityIdentifier: "button1")
        ],
        assertions: [
            .assertVisibleText(text: "Hello")
        ]
    )
    
    return ScenarioExecutionView(
        scenario: scenario,
        deviceProfile: .iPhone15,
        simulatorInfo: nil
    )
    .environmentObject(container)
}
