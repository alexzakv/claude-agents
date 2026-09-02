import Foundation
import SwiftUI
import UIKit

enum AppConfig {
    /// PayPal donation page. Set to nil to hide the donation link entirely —
    /// e.g. if App Review objects to an external tip link, shipping without
    /// it is this one edit.
    static let donationURL: URL? = nil

    static let officialPDF = URL(string: "https://www.uscis.gov/sites/default/files/document/questions-and-answers/2025-Civics-Test-128-Questions-and-Answers.pdf")!
    static let testUpdates = URL(string: "https://www.uscis.gov/citizenship/testupdates")!
}

// MARK: - Theme
// Matches the visual identity of the web flashcards (docs/index.html):
// paper ground, ink text, federal-navy accent, cream card faces.

enum Theme {
    static let paper    = Color(light: "f4f5f2", dark: "12161f")
    static let card     = Color(light: "fdfdfb", dark: "1c2230")
    static let cardBack = Color(light: "f7f6ef", dark: "202839")
    static let ink      = Color(light: "1d2433", dark: "e7e8e3")
    static let inkSoft  = Color(light: "4c5568", dark: "aab1c0")
    static let inkFaint = Color(light: "878fa0", dark: "6d7486")
    static let line     = Color(light: "d8dad2", dark: "313a4d")
    static let accent   = Color(light: "2e4a76", dark: "7d9cc9")
    static let known    = Color(light: "3d7052", dark: "7cbb96")
    static let flag     = Color(light: "9e3f38", dark: "d98a83")
    /// Text/icon color on accent-filled surfaces.
    static let accentInkColor = Color(light: "ffffff", dark: "12161f")
}

/// User-selectable appearance override (About screen).
enum AppearanceSetting: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension Color {
    /// Dynamic color from light/dark hex values ("rrggbb").
    init(light: String, dark: String) {
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        self.init(
            red: CGFloat((value >> 16) & 0xff) / 255,
            green: CGFloat((value >> 8) & 0xff) / 255,
            blue: CGFloat(value & 0xff) / 255,
            alpha: 1
        )
    }
}
