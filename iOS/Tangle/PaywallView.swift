import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Slate").ignoresSafeArea()
                VStack(spacing: 28) {
                    Spacer()

                    Image(systemName: "cable.connector")
                        .font(.system(size: 54))
                        .foregroundStyle(Color("Cobalt"))

                    VStack(spacing: 8) {
                        Text("Tangle Pro")
                            .font(.system(.title, design: .rounded).weight(.bold))
                        Text("Tag unlimited cables and chargers, with photos for every one.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 32)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow("infinity", "Unlimited tagged cables")
                        featureRow("photo.on.rectangle", "Photos for every item")
                        featureRow("magnifyingglass", "Instant search by device or spot")
                        featureRow("tray.full.fill", "Full storage history")
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    Button {
                        Task {
                            isPurchasing = true
                            await purchases.purchase()
                            isPurchasing = false
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text(purchases.product.map { "Unlock — \($0.displayPrice)" } ?? "Unlock Pro")
                                    .font(.system(.headline, design: .rounded))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .background(Color("Cobalt"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .disabled(isPurchasing)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color("Cobalt"))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    PaywallView().environmentObject(PurchaseManager())
}
