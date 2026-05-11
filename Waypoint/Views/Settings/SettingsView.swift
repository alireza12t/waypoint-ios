import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("iCloudEnabled")        private var iCloudEnabled        = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("defaultCurrency")      private var defaultCurrency      = "CAD"

    private let currencies = ["CAD","USD","EUR","GBP","JPY","AUD","CHF","SEK","MXN"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("iCloud Sync", isOn: $iCloudEnabled)
                    if iCloudEnabled {
                        Label("Syncing to your private iCloud", systemImage: "checkmark.icloud.fill")
                            .font(.caption).foregroundStyle(.green)
                    } else {
                        Text("Data stored locally on this device only")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Storage")
                }

                Section {
                    Toggle("Event reminders", isOn: $notificationsEnabled)
                    Text("A nudge before flights, tours, and timed entries. Max 2 reminders per event — nothing more.")
                        .font(.caption).foregroundStyle(.secondary)
                } header: {
                    Text("Notifications")
                }

                Section {
                    Picker("Default Currency", selection: $defaultCurrency) {
                        ForEach(currencies, id: \.self) { Text($0).tag($0) }
                    }
                } header: {
                    Text("Defaults")
                }

                Section {
                    HStack { Text("Version"); Spacer(); Text("1.0.0").foregroundStyle(.secondary) }
                    Link("View on GitHub",
                         destination: URL(string: "https://github.com/alireza12t/waypoint-ios")!)
                    Link("Report an Issue",
                         destination: URL(string: "https://github.com/alireza12t/waypoint-ios/issues")!)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
