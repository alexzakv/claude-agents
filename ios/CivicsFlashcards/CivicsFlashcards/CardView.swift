import SwiftUI

struct CardView: View {
    let card: Card
    let isKnown: Bool
    let isFlagged: Bool
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            front
                .opacity(isFlipped ? 0 : 1)
            back
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isFlipped)
        .onTapGesture { isFlipped.toggle() }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double-tap to flip the card")
    }

    private func cardBackground(_ fill: Color) -> some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(fill)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Theme.line)
            )
            .shadow(color: .black.opacity(0.10), radius: 12, y: 5)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Nº \(card.id)")
                .font(.footnote.weight(.bold))
                .foregroundStyle(Theme.accent)
            Text(Deck.sectionNames[card.section])
                .font(.caption2)
                .textCase(.uppercase)
                .foregroundStyle(Theme.inkFaint)
                .lineLimit(2)
            Spacer(minLength: 8)
            if isKnown {
                badge("Known", color: Theme.known)
            }
            if isFlagged {
                badge("Review", color: Theme.flag)
            }
        }
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }

    private var front: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            Spacer()
            Text(card.question)
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text("Tap to reveal the answer · swipe for the next card")
                .font(.caption)
                .foregroundStyle(Theme.inkFaint)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBackground(Theme.card))
    }

    private var back: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, 12)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.answers.count > 1 ? "Official answers" : "Official answer")
                        .font(.caption)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.inkFaint)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(card.answers, id: \.self) { answer in
                            if answer.hasPrefix("[") {
                                Text(answer)
                                    .font(.system(.footnote, design: .serif))
                                    .italic()
                                    .foregroundStyle(Theme.inkSoft)
                            } else {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Circle()
                                        .fill(Theme.accent.opacity(0.55))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    Text(answer)
                                        .font(.system(.body, design: .serif))
                                        .foregroundStyle(Theme.ink)
                                }
                            }
                        }
                    }
                    if let note = card.note {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Study note — not part of the official answer")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Theme.inkSoft)
                            Text(note)
                                .font(.footnote)
                                .foregroundStyle(Theme.inkSoft)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    }
                    Link(destination: card.sourceURL) {
                        Label(card.sourceLabel, systemImage: "checkmark.seal")
                            .font(.footnote.weight(.medium))
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBackground(Theme.cardBack))
    }
}
