import SwiftUI
import Combine  // required: SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY

@MainActor
final class DeckViewModel: ObservableObject {
    let allCards: [Card]

    @Published private(set) var deck: [Int] = []   // indices into allCards, filtered
    @Published var position = 0
    @Published var isFlipped = false

    @Published private(set) var known: Set<Int>    // card ids
    @Published private(set) var flagged: Set<Int>  // card ids

    @Published var sectionFilter: Int? = nil { didSet { rebuild() } }
    @Published var hideKnown = false { didSet { rebuild() } }
    @Published var flaggedOnly = false { didSet { rebuild() } }

    private var order: [Int]

    private static let knownKey = "civics128.known"
    private static let flaggedKey = "civics128.flagged"

    init(cards: [Card]? = nil) {
        allCards = cards ?? Deck.load()
        order = Array(allCards.indices)
        known = Set(UserDefaults.standard.array(forKey: Self.knownKey) as? [Int] ?? [])
        flagged = Set(UserDefaults.standard.array(forKey: Self.flaggedKey) as? [Int] ?? [])
        rebuild()
    }

    var currentCard: Card? {
        guard !deck.isEmpty, deck.indices.contains(position) else { return nil }
        return allCards[deck[position]]
    }

    var knownCount: Int { known.count }
    var totalCount: Int { allCards.count }

    func isKnown(_ card: Card) -> Bool { known.contains(card.id) }
    func isFlagged(_ card: Card) -> Bool { flagged.contains(card.id) }

    func next() {
        guard !deck.isEmpty else { return }
        position = (position + 1) % deck.count
        isFlipped = false
    }

    func previous() {
        guard !deck.isEmpty else { return }
        position = (position - 1 + deck.count) % deck.count
        isFlipped = false
    }

    func toggleKnown() {
        guard let card = currentCard else { return }
        if known.contains(card.id) {
            known.remove(card.id)
        } else {
            known.insert(card.id)
            flagged.remove(card.id)
        }
        persist()
        if hideKnown { rebuild(keeping: card.id) }
    }

    func toggleFlagged() {
        guard let card = currentCard else { return }
        if flagged.contains(card.id) {
            flagged.remove(card.id)
        } else {
            flagged.insert(card.id)
            known.remove(card.id)
        }
        persist()
        if flaggedOnly { rebuild(keeping: card.id) }
    }

    func sectionCounts(_ section: Int) -> (known: Int, total: Int) {
        let ids = allCards.filter { $0.section == section }.map(\.id)
        let knownCount = ids.filter { known.contains($0) }.count
        return (knownCount, ids.count)
    }

    func jump(toId id: Int) {
        if let idx = deck.firstIndex(where: { allCards[$0].id == id }) {
            position = idx
            isFlipped = false
        }
    }

    func shuffle() {
        order.shuffle()
        position = 0
        rebuild()
    }

    func resetProgress() {
        known.removeAll()
        flagged.removeAll()
        persist()
        rebuild()
    }

    private func rebuild(keeping keepId: Int? = nil) {
        deck = order.filter { index in
            let card = allCards[index]
            if let section = sectionFilter, card.section != section { return false }
            if hideKnown, known.contains(card.id) { return false }
            if flaggedOnly, !flagged.contains(card.id) { return false }
            return true
        }
        if let keepId, let idx = deck.firstIndex(where: { allCards[$0].id == keepId }) {
            position = idx
        } else {
            position = min(position, max(deck.count - 1, 0))
        }
        isFlipped = false
    }

    private func persist() {
        UserDefaults.standard.set(Array(known).sorted(), forKey: Self.knownKey)
        UserDefaults.standard.set(Array(flagged).sorted(), forKey: Self.flaggedKey)
    }
}
