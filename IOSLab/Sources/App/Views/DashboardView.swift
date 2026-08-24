import SwiftUI
import Core

struct DashboardView: View {
    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        NavigationStack {
            VStack {
                Text("IOSLab Dashboard")
                    .font(.largeTitle)
                    .padding()

                Spacer()

                VStack(spacing: 20) {
                    NavigationLink(destination: DevicesView()) {
                        DashboardCard(
                            title: "Devices",
                            icon: "iphone",
                            description: "Manage iOS Simulators"
                        )
                    }

                    NavigationLink(destination: ScenariosView()) {
                        DashboardCard(
                            title: "Scenarios",
                            icon: "film",
                            description: "Create and manage test scenarios"
                        )
                    }

                    NavigationLink(destination: LogsView()) {
                        DashboardCard(
                            title: "Logs",
                            icon: "doc.text.magnifyingglass",
                            description: "View execution logs"
                        )
                    }

                    NavigationLink(destination: SettingsView()) {
                        DashboardCard(
                            title: "Settings",
                            icon: "gearshape",
                            description: "Configure IOSLab"
                        )
                    }
                }

                Spacer()
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardCard: View {
    let title: String
    let icon: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    DashboardView()
        .environmentObject(DependencyContainer.preview)
}
