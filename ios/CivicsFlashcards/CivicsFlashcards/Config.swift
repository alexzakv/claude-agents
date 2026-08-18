import Foundation

enum AppConfig {
    /// TODO: replace with your real donation page before shipping
    /// (Buy Me a Coffee, GitHub Sponsors, PayPal.me, Ko-fi, ...).
    /// Set to nil to hide the donation link entirely — e.g. if App Review
    /// objects to an external tip link, shipping without it is one edit here.
    static let donationURL: URL? = URL(string: "https://www.buymeacoffee.com/CHANGE-ME")

    static let officialPDF = URL(string: "https://www.uscis.gov/sites/default/files/document/questions-and-answers/2025-Civics-Test-128-Questions-and-Answers.pdf")!
    static let testUpdates = URL(string: "https://www.uscis.gov/citizenship/testupdates")!
}
