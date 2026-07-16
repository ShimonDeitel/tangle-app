import SwiftUI

@main
struct TangleApp: App {
    @StateObject private var store = CableStore()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .task {
                    await purchases.refreshPurchasedState()
                }
        }
    }
}
