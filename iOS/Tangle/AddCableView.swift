import SwiftUI
import PhotosUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(TapGesture().onEnded {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
    }
}

struct AddCableView: View {
    @EnvironmentObject private var store: CableStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let onSaved: (Cable) -> Void

    @AppStorage("defaultCableKind") private var defaultCableKind = CableKind.usbC.rawValue

    @State private var label = ""
    @State private var belongsTo = ""
    @State private var kind: CableKind = .usbC
    @State private var storageLocation = ""
    @State private var notes = ""
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Cable") {
                    TextField("What is it? (e.g. Charging cable)", text: $label)
                    TextField("What does it belong to?", text: $belongsTo)
                    Picker("Type", selection: $kind) {
                        ForEach(CableKind.allCases, id: \.self) { k in
                            Label(k.rawValue, systemImage: k.icon).tag(k)
                        }
                    }
                }

                Section("Where it lives") {
                    TextField("Storage spot (e.g. Kitchen drawer)", text: $storageLocation)
                }

                Section("Photo") {
                    if purchases.isPro {
                        PhotosPicker(selection: $pickedPhoto, matching: .images) {
                            Label(pickedImage == nil ? "Attach a photo" : "Photo attached", systemImage: "camera.fill")
                        }
                        .onChange(of: pickedPhoto) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    pickedImage = UIImage(data: data)
                                }
                            }
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            Label("Attach a photo", systemImage: "lock.fill")
                        }
                    }
                }

                Section("Notes") {
                    TextField("Distinguishing details", text: $notes, axis: .vertical)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .dismissKeyboardOnTap()
            .navigationTitle("New Cable")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(label.isEmpty || belongsTo.isEmpty)
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .onAppear {
                if let preferred = CableKind(rawValue: defaultCableKind) {
                    kind = preferred
                }
            }
        }
    }

    private func save() {
        if !purchases.isPro && store.cables.count >= 3 {
            showPaywall = true
            return
        }
        let cable = store.addCable(
            label: label,
            belongsTo: belongsTo,
            kind: kind,
            storageLocation: storageLocation,
            notes: notes,
            photo: pickedImage
        )
        dismiss()
        onSaved(cable)
    }
}

#Preview {
    AddCableView(onSaved: { _ in })
        .environmentObject(CableStore())
        .environmentObject(PurchaseManager())
}
