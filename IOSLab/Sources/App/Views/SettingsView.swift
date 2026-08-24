import SwiftUI
import Core

struct SettingsView: View {
    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Toggle("Debug Mode", isOn: Binding(
                        get: { container.logger.logLevel == .debug },
                        set: { isOn in
                            container.logger.logLevel = isOn ? .debug : .info
                        }
                    ))
                }

                Section("About") {
                    Text("IOSLab")
                        .font(.headline)
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("A tool for testing iOS apps with simulators")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DependencyContainer.preview)
}
