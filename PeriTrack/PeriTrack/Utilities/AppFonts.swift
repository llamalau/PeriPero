import SwiftUI

enum AppFonts {
    // MARK: - Fraunces (Primary / Display)
    // "Welcome to the Summer of your Life"

    static func fraunces(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold, .heavy, .black:
            name = "Fraunces-Bold"
        case .semibold:
            name = "Fraunces-SemiBold"
        case .light, .ultraLight, .thin:
            name = "Fraunces-Light"
        default:
            name = "Fraunces-Regular"
        }
        // Variable font registered as "Fraunces" family
        // Try custom font, fall back to system serif
        return .custom(name, size: size, relativeTo: .body)
    }

    static func frauncesDisplay(size: CGFloat) -> Font {
        .custom("Fraunces", size: size, relativeTo: .largeTitle)
    }

    // MARK: - Atkinson Hyperlegible (Body / Secondary)

    static func body(size: CGFloat = 16) -> Font {
        .custom("AtkinsonHyperlegible-Regular", size: size, relativeTo: .body)
    }

    static func bodyBold(size: CGFloat = 16) -> Font {
        .custom("AtkinsonHyperlegible-Bold", size: size, relativeTo: .body)
    }

    static func bodyItalic(size: CGFloat = 16) -> Font {
        .custom("AtkinsonHyperlegible-Italic", size: size, relativeTo: .body)
    }

    static func caption(size: CGFloat = 12) -> Font {
        .custom("AtkinsonHyperlegible-Regular", size: size, relativeTo: .caption)
    }

    static func captionBold(size: CGFloat = 12) -> Font {
        .custom("AtkinsonHyperlegible-Bold", size: size, relativeTo: .caption)
    }

    // MARK: - Convenience

    static let largeTitle = frauncesDisplay(size: 32)
    static let title = frauncesDisplay(size: 26)
    static let title2 = frauncesDisplay(size: 22)
    static let title3 = frauncesDisplay(size: 18)
    static let headline = bodyBold(size: 16)
    static let subheadline = body(size: 14)
    static let footnote = caption(size: 13)
}
