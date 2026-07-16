import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("showStorageLocation") private var showStorageLocation = true
    @AppStorage("defaultCableKind") private var defaultCableKind = CableKind.usbC.rawValue

    @State private var showPaywall = false
    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Display") {
                    Toggle("Show storage spot on cards", isOn: $showStorageLocation)
                    Picker("Default cable type", selection: $defaultCableKind) {
                        ForEach(CableKind.allCases, id: \.self) { k in
                            Text(k.rawValue).tag(k.rawValue)
                        }
                    }
                }

                Section("Tangle Pro") {
                    if purchases.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Color("Cobalt"))
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Unlock Pro", systemImage: "star.fill")
                        }
                    }
                    Button {
                        Task {
                            isRestoring = true
                            await purchases.restore()
                            isRestoring = false
                        }
                    } label: {
                        HStack {
                            Text("Restore Purchases")
                            if isRestoring {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                }

                Section("About") {
                    Link(destination: URL(string: "https://shimondeitel.github.io/cool-apps-legal/tangle/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    Link(destination: URL(string: "mailto:s0533495227@gmail.com")!) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
        .tint(Color("Cobalt"))
    }
}

#Preview {
    SettingsView().environmentObject(PurchaseManager())
}
