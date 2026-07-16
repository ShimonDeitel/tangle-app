import XCTest
@testable import Tangle

final class TangleTests: XCTestCase {
    @MainActor
    func testAddAndDeleteCable() {
        let store = CableStore()
        let before = store.cables.count
        let cable = store.addCable(
            label: "MacBook Charger",
            belongsTo: "MacBook Pro",
            kind: .usbC,
            storageLocation: "Office drawer",
            notes: "",
            photo: nil
        )
        XCTAssertEqual(store.cables.count, before + 1)
        XCTAssertEqual(cable.label, "MacBook Charger")
        store.delete(cable)
        XCTAssertEqual(store.cables.count, before)
    }

    @MainActor
    func testSearchFiltersByLabelBelongsToAndLocation() {
        let store = CableStore()
        store.addCable(label: "iPhone Cable", belongsTo: "iPhone", kind: .lightning, storageLocation: "Kitchen drawer", notes: "", photo: nil)
        store.addCable(label: "TV Cable", belongsTo: "Living Room TV", kind: .hdmi, storageLocation: "Media console", notes: "", photo: nil)

        store.searchText = "iphone"
        XCTAssertEqual(store.filtered.count, 1)
        XCTAssertEqual(store.filtered.first?.label, "iPhone Cable")

        store.searchText = "console"
        XCTAssertEqual(store.filtered.count, 1)
        XCTAssertEqual(store.filtered.first?.label, "TV Cable")

        store.searchText = ""
        XCTAssertEqual(store.filtered.count, 2)
    }

    func testCableKindIcons() {
        XCTAssertEqual(CableKind.usbC.icon, "cable.connector")
        XCTAssertEqual(CableKind.hdmi.icon, "tv")
        XCTAssertEqual(CableKind.other.icon, "questionmark.circle")
    }

    @MainActor
    func testCablesSortedNewestFirst() {
        let store = CableStore()
        let first = store.addCable(label: "First", belongsTo: "A", kind: .usbA, storageLocation: "", notes: "", photo: nil)
        let second = store.addCable(label: "Second", belongsTo: "B", kind: .usbA, storageLocation: "", notes: "", photo: nil)
        XCTAssertEqual(store.filtered.first?.id, second.id)
        store.delete(first)
        store.delete(second)
    }
}
