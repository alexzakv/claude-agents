import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: Int
    let section: Int
    let question: String
    let answers: [String]
    let note: String?
    let usesTestUpdates: Bool

    var sourceURL: URL {
        if usesTestUpdates {
            return URL(string: "https://www.uscis.gov/citizenship/testupdates")!
        }
        return URL(string: "https://www.uscis.gov/sites/default/files/document/questions-and-answers/2025-Civics-Test-128-Questions-and-Answers.pdf")!
    }

    var sourceLabel: String {
        usesTestUpdates
            ? "Check current answer at uscis.gov"
            : "Verify in the official USCIS PDF"
    }
}

enum Deck {
    static let sectionNames = [
        "American Government · Principles of American Government",
        "American Government · System of Government",
        "American Government · Rights and Responsibilities",
        "American History · Colonial Period and Independence",
        "American History · 1800s",
        "American History · Recent History",
        "Symbols and Holidays · Symbols",
        "Symbols and Holidays · Holidays",
    ]

    static func load() -> [Card] {
        guard
            let url = Bundle.main.url(forResource: "civics128", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let cards = try? JSONDecoder().decode([Card].self, from: data)
        else {
            assertionFailure("civics128.json missing from bundle or malformed")
            return []
        }
        return cards.sorted { $0.id < $1.id }
    }
}
