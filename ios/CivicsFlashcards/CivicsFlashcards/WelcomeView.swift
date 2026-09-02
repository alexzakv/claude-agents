import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("★")
                            .font(.system(size: 34))
                            .foregroundStyle(Theme.flag)
                        Text("Welcome to Civics 128")
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.ink)
                        Text("CURRENT FOR 2026 INTERVIEWS")
                            .font(.caption2.weight(.bold))
                            .kerning(1.1)
                            .foregroundStyle(Theme.flag)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.flag.opacity(0.12), in: Capsule())
                        Text("The new 128-question citizenship test, in one deck.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.inkSoft)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 16)

                    feature(icon: "rectangle.on.rectangle",
                            title: "All 128 official questions",
                            text: "Every question and acceptable answer, word for word from the official USCIS study materials.")
                    feature(icon: "hand.draw",
                            title: "Swipe, flip, remember",
                            text: "Tap a card to reveal the answers, swipe for the next one, and mark cards as known or flag them for review.")
                    feature(icon: "checkmark.seal",
                            title: "Verify at the source",
                            text: "Every card links to the official USCIS document — including the answers that change after elections.")
                    feature(icon: "wifi.slash",
                            title: "Private and offline",
                            text: "Works anywhere with no account and no tracking. Your progress stays on this device.")
                }
                .padding(.horizontal, 24)
            }
            VStack(spacing: 10) {
                Button(action: onStart) {
                    Text("Start Studying")
                        .font(.headline)
                        .foregroundStyle(Theme.accentInkColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                Text("Not affiliated with USCIS or any government agency.")
                    .font(.caption2)
                    .foregroundStyle(Theme.inkFaint)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .background(Theme.paper)
    }

    private func feature(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(Theme.inkSoft)
            }
        }
    }
}

#Preview {
    WelcomeView(onStart: {})
}
