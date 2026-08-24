import SwiftUI
import Core
import ScenarioEngine

/// View for displaying the execution timeline of a scenario.
public struct ExecutionTimelineView: View {
    @EnvironmentObject private var container: DependencyContainer
    @ObservedObject public var runner: ScenarioRunner
    @State private var selectedActionIndex: Int?
    @State private var selectedAssertionIndex: Int?

    public init(runner: ScenarioRunner) {
        self.runner = runner
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with progress
                ExecutionHeader(runner: runner)

                // Timeline
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Actions section
                        if !runner.actionResults.isEmpty {
                            SectionView(title: "Actions") {
                                ForEach(Array(runner.actionResults.enumerated()), id: \.element.id) { index, result in
                                    ActionResultRow(
                                        result: result,
                                        index: index,
                                        isSelected: selectedActionIndex == index
                                    )
                                    .onTapGesture {
                                        selectedActionIndex = index
                                        selectedAssertionIndex = nil
                                    }
                                }
                            }
                        }

                        // Assertions section
                        if !runner.assertionResults.isEmpty {
                            SectionView(title: "Assertions") {
                                ForEach(Array(runner.assertionResults.enumerated()), id: \.element.id) { index, result in
                                    AssertionResultRow(
                                        result: result,
                                        index: index,
                                        isSelected: selectedAssertionIndex == index
                                    )
                                    .onTapGesture {
                                        selectedActionIndex = nil
                                        selectedAssertionIndex = index
                                    }
                                }
                            }
                        }

                        // Empty state
                        if runner.actionResults.isEmpty && runner.assertionResults.isEmpty {
                            VStack {
                                Spacer()
                                Text("No execution data yet")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Execution Timeline")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Refresh action
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

/// Header view showing execution progress.
struct ExecutionHeader: View {
    @ObservedObject var runner: ScenarioRunner

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // State and title
            HStack {
                StateIndicator(state: runner.state)
                
                VStack(alignment: .leading) {
                    Text("Execution \(stateDescription)")
                        .font(.headline)
                    
                    if let error = runner.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Spacer()

                // Time
                Text(formatTime(runner.progress.elapsedTime))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            ProgressView(value: progressValue, total: 1.0)
                .tint(progressColor)

            // Progress text
            HStack {
                if runner.progress.totalActions > 0 {
                    Text("Actions: \(runner.progress.currentActionIndex)/\(runner.progress.totalActions)")
                        .font(.caption)
                }
                
                Spacer()
                
                if runner.progress.totalAssertions > 0 {
                    Text("Assertions: \(runner.progress.currentAssertionIndex)/\(runner.progress.totalAssertions)")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(radius: 1)
    }

    private var stateDescription: String {
        switch runner.state {
        case .pending: return "Pending"
        case .running: return "Running"
        case .paused: return "Paused"
        case .cancelled: return "Cancelled"
        case .completed(let success): return success ? "Completed" : "Failed"
        case .failed: return "Failed"
        }
    }

    private var progressValue: Double {
        let actionProgress = runner.progress.totalActions > 0 ? 
            Double(runner.progress.currentActionIndex) / Double(runner.progress.totalActions) : 0.0
        let assertionProgress = runner.progress.totalAssertions > 0 ?
            Double(runner.progress.currentAssertionIndex) / Double(runner.progress.totalAssertions) : 0.0
        
        return (actionProgress + assertionProgress) / 2.0
    }

    private var progressColor: Color {
        switch runner.state {
        case .pending, .running, .paused: return .blue
        case .cancelled: return .gray
        case .completed(let success): return success ? .green : .red
        case .failed: return .red
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0s"
    }
}

/// State indicator view.
struct StateIndicator: View {
    let state: ExecutionState

    var color: Color {
        switch state {
        case .pending: return .gray
        case .running: return .blue
        case .paused: return .yellow
        case .cancelled: return .gray
        case .completed(let success): return success ? .green : .red
        case .failed: return .red
        }
    }

    var icon: String {
        switch state {
        case .pending: return "clock"
        case .running: return "play.fill"
        case .paused: return "pause.fill"
        case .cancelled: return "xmark"
        case .completed(let success): return success ? "checkmark" : "xmark"
        case .failed: return "xmark"
        }
    }

    var body: some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundStyle(color)
            .frame(width: 30, height: 30)
            .background(color.opacity(0.2))
            .cornerRadius(6)
    }
}

/// Section view with title.
struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 4)
            
            content
        }
    }
}

/// Row for displaying action result.
struct ActionResultRow: View {
    let result: ActionResult
    let index: Int
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Index
            Text("\(index)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)

            // Icon
            Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(result.success ? .green : .red)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(actionDescription)
                    .font(.subheadline)
                
                if let output = result.output {
                    Text(output)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let error = result.error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            // Time
            Text(formatTime(result.duration))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }

    private var actionDescription: String {
        switch result.action {
        case .launchApp(let bundleID):
            return "Launch App: \(bundleID)"
        case .tapElement(let identifier):
            return "Tap: \(identifier)"
        case .enterText(let text, let identifier):
            return "Enter Text: \(identifier)"
        case .swipe(let direction, _):
            return "Swipe: \(direction)"
        case .rotateDevice(let orientation):
            return "Rotate: \(orientation)"
        case .changeNetworkProfile(let profile):
            return "Network: \(profile.profileType)"
        case .sendToBackground:
            return "Send to Background"
        case .sendToForeground:
            return "Send to Foreground"
        case .injectPushNotification(let payload):
            return "Push: \(payload.title)"
        case .simulateLocationUpdate(let lat, let lon):
            return "Location: (\(lat), \(lon))"
        case .captureScreenshot(let name):
            return "Screenshot: \(name ?? "unnamed")"
        case .delay(let duration):
            return "Delay: \(duration)s"
        case .custom(let command):
            return "Custom: \(command)"
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        if interval < 1 {
            return String(format: "%.1fs", interval)
        } else if interval < 60 {
            return String(format: "%.1fs", interval)
        } else {
            let minutes = Int(interval) / 60
            let seconds = Int(interval) % 60
            return "\(minutes)m \(seconds)s"
        }
    }
}

/// Row for displaying assertion result.
struct AssertionResultRow: View {
    let result: AssertionResult
    let index: Int
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Index
            Text("\(index)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)

            // Icon
            Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(result.passed ? .green : .red)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(assertionDescription)
                    .font(.subheadline)
                
                if let message = result.message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(result.passed ? .green : .red)
                }
                
                if let error = result.error {
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Spacer()

            // Status
            Text(result.passed ? "PASS" : "FAIL")
                .font(.caption)
                .foregroundStyle(result.passed ? .green : .red)
                .padding(4)
                .background(result.passed ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }

    private var assertionDescription: String {
        switch result.assertion {
        case .assertVisibleText(let text):
            return "Visible Text: \(text)"
        case .assertAccessibilityLabel(let label):
            return "Label: \(label)"
        case .assertElementExists(let identifier):
            return "Element Exists: \(identifier)"
        case .assertElementDoesNotExist(let identifier):
            return "Element Not Exists: \(identifier)"
        case .assertNavigationState(let route):
            return "Route: \(route)"
        case .assertAPIRequestData(let endpoint, _):
            return "API: \(endpoint)"
        case .assertScreenshotMatchesBaseline(let name):
            return "Screenshot: \(name)"
        case .assertTrue(let expression):
            return "True: \(expression)"
        case .assertFalse(let expression):
            return "False: \(expression)"
        }
    }
}

// MARK: - Previews

#Preview {
    let container = DependencyContainer.preview
    let runner = ScenarioRunner(
        actionExecutor: DefaultActionExecutor(simctlClient: container.simctlClient, logger: container.logger),
        assertionValidator: DefaultAssertionValidator(logger: container.logger),
        logger: container.logger,
        deviceProfileStore: container.deviceProfileStore,
        simctlClient: container.simctlClient
    )
    return ExecutionTimelineView(runner: runner)
        .environmentObject(container)
}
