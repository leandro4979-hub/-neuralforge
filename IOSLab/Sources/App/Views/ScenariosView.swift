import SwiftUI
import Core
import ScenarioEngine

struct ScenariosView: View {
    @EnvironmentObject private var container: DependencyContainer
    @StateObject private var scenarioStore: ScenarioStore
    @State private var selectedScenario: Scenario?
    @State private var showCreateScenarioSheet = false
    @State private var showImportSheet = false
    @State private var showExportSheet = false
    @State private var importURL: URL?
    @State private var exportURL: URL?

    init() {
        let container = DependencyContainer.preview
        _scenarioStore = StateObject(
            wrappedValue: ScenarioStore(
                logger: container.logger,
                parser: container.scenarioParser,
                validator: container.scenarioValidator
            )
        )
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Scenarios") {
                    if scenarioStore.isLoading {
                        ProgressView()
                    } else if scenarioStore.scenarios.isEmpty {
                        Text("No scenarios found")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(scenarioStore.scenarios) { scenario in
                            ScenarioRow(
                                scenario: scenario,
                                isSelected: selectedScenario?.id == scenario.id,
                                onDelete: {
                                    Task {
                                        do {
                                            try scenarioStore.deleteScenario(scenario)
                                        } catch {
                                            container.logger.error("Failed to delete scenario: \(error)")
                                        }
                                    }
                                }
                            )
                            .onTapGesture {
                                selectedScenario = scenario
                            }
                        }
                    }
                }
            }
            .navigationTitle("Scenarios")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Create Scenario") {
                            showCreateScenarioSheet = true
                        }
                        Button("Import Scenario") {
                            showImportSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { scenarioStore.loadScenarios() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(scenarioStore.isLoading)
                }
            }
            .refreshable {
                scenarioStore.loadScenarios()
            }
            .sheet(isPresented: $showCreateScenarioSheet) {
                CreateScenarioSheet(
                    scenarioStore: scenarioStore,
                    deviceProfileStore: container.deviceProfileStore
                )
            }
            .fileImporter(
                isPresented: $showImportSheet,
                allowedContentTypes: [.json, .yaml],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importURL = url
                    Task {
                        do {
                            try scenarioStore.importScenario(from: url)
                        } catch {
                            container.logger.error("Failed to import scenario: \(error)")
                        }
                    }
                case .failure(let error):
                    container.logger.error("Failed to import scenario: \(error)")
                }
            }
            .fileExporter(
                isPresented: $showExportSheet,
                document: ScenarioDocument(scenario: selectedScenario ?? Scenario()),
                contentType: .json,
                defaultFilename: selectedScenario?.name ?? "Untitled"
            ) { result in
                switch result {
                case .success(let url):
                    exportURL = url
                case .failure(let error):
                    container.logger.error("Failed to export scenario: \(error)")
                }
            }
            .onChange(of: selectedScenario) { newValue in
                if newValue != nil {
                    showExportSheet = true
                }
            }
        }
    }
}

// MARK: - Scenario Row
struct ScenarioRow: View {
    let scenario: Scenario
    let isSelected: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(scenario.name)
                .font(.headline)
            Text(scenario.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Text("Actions: \(scenario.actions.count)")
                    .font(.caption)
                Spacer()
                Text("Assertions: \(scenario.assertions.count)")
                    .font(.caption)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Create Scenario Sheet
struct CreateScenarioSheet: View {
    @ObservedObject var scenarioStore: ScenarioStore
    @ObservedObject var deviceProfileStore: DeviceProfileStore
    @State private var name = ""
    @State private var description = ""
    @State private var selectedDeviceProfile: DeviceProfile?
    @Environment(\dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Scenario Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }

                Section("Device Profile") {
                    Picker("Device Profile", selection: $selectedDeviceProfile) {
                        Text("None").tag(nil as DeviceProfile?)
                        ForEach(deviceProfileStore.profiles) { profile in
                            Text(profile.name)
                                .tag(profile as DeviceProfile?)
                        }
                    }
                }
            }
            .navigationTitle("Create Scenario")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let scenario = Scenario(
                            name: name,
                            description: description,
                            deviceProfileID: selectedDeviceProfile?.id
                        )
                        Task {
                            do {
                                try scenarioStore.saveScenario(scenario)
                                dismiss()
                            } catch {
                                // Handle error
                            }
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

// MARK: - Scenario Document (for File Export)
struct ScenarioDocument: FileDocument {
    var scenario: Scenario

    init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }

    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let parser = ScenarioParser(logger: Logger(component: "ScenarioDocument"))
        scenario = try parser.parseJSON(string)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let parser = ScenarioParser(logger: Logger(component: "ScenarioDocument"))
        let string = try parser.serializeJSON(scenario)
        let data = string.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Previews
#Preview {
    ScenariosView()
        .environmentObject(DependencyContainer.preview)
}
