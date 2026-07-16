import SwiftUI

/// Signature animation: a luggage-style tag swings in and "clips" onto
/// the cable icon with a snap, then the label flips into view.
struct TagSnapView: View {
    let label: String
    let belongsTo: String
    let onDone: () -> Void

    @State private var tagOffset: CGFloat = -220
    @State private var tagRotation: Double = -35
    @State private var tagOpacity: Double = 0
    @State private var showText = false
    @State private var iconScale: CGFloat = 1

    var body: some View {
        ZStack {
            Color("Ink").opacity(0.55).ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Image(systemName: "cable.connector")
                        .font(.system(size: 60))
                        .foregroundStyle(Color("Slate"))
                        .frame(width: 140, height: 140)
                        .background(Color("Cobalt"))
                        .clipShape(Circle())
                        .scaleEffect(iconScale)

                    TagShape()
                        .fill(Color("Slate"))
                        .frame(width: 90, height: 50)
                        .overlay(
                            Circle()
                                .fill(Color("Ink"))
                                .frame(width: 10, height: 10)
                                .offset(x: -32)
                        )
                        .offset(x: 70, y: -55)
                        .rotationEffect(.degrees(tagRotation), anchor: .topLeading)
                        .offset(x: tagOffset)
                        .opacity(tagOpacity)
                }
                .frame(height: 200)

                VStack(spacing: 6) {
                    Text(label)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    if showText {
                        Text("TAGGED TO \(belongsTo.uppercased())")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .tracking(1)
                            .foregroundStyle(Color("Cobalt"))
                            .transition(.opacity)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                tagOpacity = 1
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1)) {
                tagOffset = 0
                tagRotation = 8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                    iconScale = 1.12
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.12)) {
                    iconScale = 1.0
                }
                withAnimation(.easeIn(duration: 0.3)) {
                    showText = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onDone()
            }
        }
    }
}

private struct TagShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let notch: CGFloat = 18
        path.move(to: CGPoint(x: notch, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: notch, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height / 2))
        path.closeSubpath()
        return path
    }
}
