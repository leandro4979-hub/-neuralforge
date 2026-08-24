import SwiftUI
import Core
import SimulatorIntegration

struct DevicesView: View {
    @EnvironmentObject private var container: DependencyContainer
    @StateObject private var viewModel = DevicesViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Available Simulators") {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.simulators.isEmpty {
                        Text("No simulators found")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.simulators) { simulator in
                            SimulatorRow(simulator: simulator)
                        }
                    }
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .refreshable {
                viewModel.refresh()
            }
            .onAppear {
                viewModel.container = container
                viewModel.refresh()
            }
        }
    }
}

struct SimulatorRow: View {
    let simulator: SimulatorInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(simulator.name)
                .font(.headline)
            HStack {
                Text(simulator.deviceType)
                    .font(.subheadline)
                Spacer()
                Text(simulator.runtime)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(simulator.udid)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                StateBadge(state: simulator.state)
            }
        }
    }
}

struct StateBadge: View {
    let state: SimulatorInfo.SimulatorState

    var color: Color {
        switch state {
        case .booted: return .green
        case .shutdown: return .gray
        case .booting, .creating: return .yellow
        case .shuttingDown: return .orange
        case .notInstalled, .unknown: return .red
        }
    }

    var label: String {
        switch state {
        case .booted: return "Booted"
        case .shutdown: return "Shutdown"
        case .booting: return "Booting"
        case .creating: return "Creating"
        case .shuttingDown: return "Shutting Down"
        case .notInstalled: return "Not Installed"
        case .unknown: return "Unknown"
        }
    }

    var body: some View {
        Text(label)
            .font(.caption)
            .padding(4)
            .background(color)
            .foregroundStyle(.white)
            .cornerRadius(4)
    }
}

class DevicesViewModel: ObservableObject {
    @Published var simulators: [SimulatorInfo] = []
    @Published var isLoading = false
    @Published var error: Error?

    var container: DependencyContainer?

    func refresh() {
        guard let container = container else { return }
        
        isLoading = true
        error = nil

        Task {
            do {
                simulators = try await container.simulatorDiscovery.discoverSimulators()
            } catch {
                self.error = error
                container.logger.error("Failed to load simulators: \(error)")
            }
            isLoading = false
        }
    }
}

#Preview {
    DevicesView()
        .environmentObject(DependencyContainer.preview)
}
