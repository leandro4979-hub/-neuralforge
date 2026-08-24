import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            DevicesView()
                .tabItem {
                    Label("Devices", systemImage: "iphone")
                }

            ScenariosView()
                .tabItem {
                    Label("Scenarios", systemImage: "film")
                }

            LogsView()
                .tabItem {
                    Label("Logs", systemImage: "doc.text.magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DependencyContainer.preview)
}
