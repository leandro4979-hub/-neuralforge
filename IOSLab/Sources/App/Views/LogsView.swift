import SwiftUI
import Core

struct LogsView: View {
    @EnvironmentObject private var container: DependencyContainer
    @StateObject private var viewModel = LogsViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.logEntries) { entry in
                LogEntryRow(entry: entry)
            }
            .navigationTitle("Logs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.clearLogs()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .onAppear {
                viewModel.container = container
            }
        }
    }
}

struct LogEntryRow: View {
    let entry: LogEntry

    var color: Color {
        switch entry.level {
        case .debug: return .gray
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .orange
        case .critical: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.level.rawValue.uppercased())
                    .font(.caption)
                    .padding(4)
                    .background(color)
                    .foregroundStyle(.white)
                    .cornerRadius(4)
                Spacer()
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(entry.component)
                .font(.headline)
            Text(entry.message)
                .font(.subheadline)
        }
    }
}

class LogsViewModel: ObservableObject {
    @Published var logEntries: [LogEntry] = []
    
    var container: DependencyContainer?

    func clearLogs() {
        logEntries.removeAll()
    }
}

#Preview {
    LogsView()
        .environmentObject(DependencyContainer.preview)
}
