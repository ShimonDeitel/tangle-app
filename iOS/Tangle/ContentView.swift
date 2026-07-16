import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: CableStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showPaywall = false
    @State private var showSettings = false
    @State private var justAdded: Cable?

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Slate").ignoresSafeArea()

                if store.cables.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            summaryCard
                            ForEach(store.filtered) { cable in
                                CableCard(cable: cable)
                            }
                        }
                        .padding()
                    }
                    .searchable(text: $store.searchText, prompt: "Search by device or spot")
                }
            }
            .navigationTitle("Tangle")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if !purchases.isPro && store.cables.count >= 3 {
                            showPaywall = true
                        } else {
                            showAdd = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddCableView(onSaved: { cable in justAdded = cable })
                    .environmentObject(store)
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(purchases)
            }
            .fullScreenCover(item: $justAdded) { cable in
                TagSnapView(label: cable.label, belongsTo: cable.belongsTo) {
                    justAdded = nil
                }
            }
        }
        .tint(Color("Cobalt"))
    }

    private var summaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tagged")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(store.cables.count)")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(Color("Ink"))
            }
            Spacer()
            Text("Never untangle a mystery cable")
                .font(.caption.bold())
                .foregroundStyle(Color("Cobalt"))
        }
        .padding()
        .background(Color("CardSlate"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "cable.connector")
                .font(.system(size: 56))
                .foregroundStyle(Color("Cobalt"))
            Text("Never wonder what this cable is for")
                .font(.system(.title2, design: .rounded).weight(.bold))
            Text("Tag every charger and cable with what it belongs to and where it's stored — Tangle remembers so you don't have to.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Button {
                showAdd = true
            } label: {
                Label("Tag a Cable", systemImage: "plus")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color("Cobalt"))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }
}

private struct CableCard: View {
    @EnvironmentObject private var store: CableStore
    @AppStorage("showStorageLocation") private var showStorageLocation = true
    let cable: Cable

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: cable.kind.icon)
                .font(.title2)
                .foregroundStyle(Color("Cobalt"))
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(cable.label)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color("Ink"))
                Text("Belongs to \(cable.belongsTo)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if showStorageLocation && !cable.storageLocation.isEmpty {
                    Label(cable.storageLocation, systemImage: "mappin.circle")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color("CardSlate"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .swipeActions {
            Button(role: .destructive) {
                store.delete(cable)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CableStore())
        .environmentObject(PurchaseManager())
}
