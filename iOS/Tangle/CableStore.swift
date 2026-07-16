import Foundation
import SwiftUI
import UIKit

enum CableKind: String, Codable, CaseIterable {
    case usbC = "USB-C"
    case lightning = "Lightning"
    case usbA = "USB-A"
    case barrel = "Barrel/DC"
    case hdmi = "HDMI"
    case other = "Other"

    var icon: String {
        switch self {
        case .usbC, .usbA, .lightning: return "cable.connector"
        case .barrel: return "bolt.circle"
        case .hdmi: return "tv"
        case .other: return "questionmark.circle"
        }
    }
}

struct Cable: Identifiable, Codable, Equatable {
    let id: UUID
    var label: String
    var belongsTo: String
    var kind: CableKind
    var storageLocation: String
    var notes: String
    var hasPhoto: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        label: String,
        belongsTo: String,
        kind: CableKind,
        storageLocation: String,
        notes: String = "",
        hasPhoto: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.label = label
        self.belongsTo = belongsTo
        self.kind = kind
        self.storageLocation = storageLocation
        self.notes = notes
        self.hasPhoto = hasPhoto
        self.createdAt = createdAt
    }
}

@MainActor
final class CableStore: ObservableObject {
    @Published private(set) var cables: [Cable] = []
    @Published var searchText: String = ""

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("cables.json")
    }()

    private let photosDir: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CablePhotos")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    init() {
        load()
    }

    var filtered: [Cable] {
        let sorted = cables.sorted { $0.createdAt > $1.createdAt }
        guard !searchText.isEmpty else { return sorted }
        let q = searchText.lowercased()
        return sorted.filter {
            $0.label.lowercased().contains(q) ||
            $0.belongsTo.lowercased().contains(q) ||
            $0.storageLocation.lowercased().contains(q)
        }
    }

    @discardableResult
    func addCable(
        label: String,
        belongsTo: String,
        kind: CableKind,
        storageLocation: String,
        notes: String,
        photo: UIImage?
    ) -> Cable {
        let cable = Cable(
            label: label,
            belongsTo: belongsTo,
            kind: kind,
            storageLocation: storageLocation,
            notes: notes,
            hasPhoto: photo != nil
        )
        if let photo, let data = photo.jpegData(compressionQuality: 0.85) {
            try? data.write(to: photosDir.appendingPathComponent("\(cable.id).jpg"))
        }
        cables.append(cable)
        save()
        return cable
    }

    func delete(_ cable: Cable) {
        cables.removeAll { $0.id == cable.id }
        try? FileManager.default.removeItem(at: photosDir.appendingPathComponent("\(cable.id).jpg"))
        save()
    }

    func photo(for cable: Cable) -> UIImage? {
        guard cable.hasPhoto else { return nil }
        return UIImage(contentsOfFile: photosDir.appendingPathComponent("\(cable.id).jpg").path)
    }

    private func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([Cable].self, from: data) else { return }
        cables = decoded
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(cables) else { return }
        try? data.write(to: fileURL)
    }
}
