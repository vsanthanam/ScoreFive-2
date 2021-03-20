//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

public extension UIColor {

    // MARK: - Semantic Colors

    static var transparent: UIColor {
        ColorPalette.Transparent
    }

    static var shadowColor: UIColor {
        dynamicDarkPrimary
    }

    static var backgroundPrimary: UIColor {
        dynamicLightPrimary
    }

    static var backgroundSecondary: UIColor {
        dynamicLightSecondary
    }

    static var backgroundTertiary: UIColor {
        dynamicLightTertiary
    }

    static var backgroundInversePrimary: UIColor {
        dynamicDarkPrimary
    }

    static var backgroundInverseSecondary: UIColor {
        dynamicDarkSecondary
    }

    static var backgrondInverserTertiary: UIColor {
        dynamicDarkTertiary
    }

    static var contentPrimary: UIColor {
        dynamicDarkPrimary
    }

    static var contentSecondary: UIColor {
        dynamicDarkSecondary
    }

    static var contentTertiary: UIColor {
        dynamicDarkTertiary
    }

    static var contentInversePrimary: UIColor {
        dynamicLightPrimary
    }

    static var contentInverseSecondary: UIColor {
        dynamicLightSecondary
    }

    static var contentInverseTertiary: UIColor {
        dynamicLightTertiary
    }

    static var contentOnColorPrimary: UIColor {
        staticLightPrimary
    }

    static var contentOnColorSecondary: UIColor {
        staticLightSecondary
    }

    static var contentOnColorInversePrimary: UIColor {
        staticDarkPrimary
    }

    static var contentOnColorInverseSecondary: UIColor {
        staticDarkSecondary
    }

    static var contentOnColorInverseTertiary: UIColor {
        staticDarkTertiary
    }

    static var contentAccentPrimary: UIColor {
        staticThemePrimary
    }

    static var contentAccentSecondary: UIColor {
        staticThemeSecondary
    }

    static var controlDisabled: UIColor {
        ColorPalette.Grey500
    }

    static var contentPositive: UIColor {
        ColorPalette.Green700
    }

    static var contentNegative: UIColor {
        ColorPalette.Red700
    }

    // MARK: - Implementation Colors

    private static let staticDarkPrimary: UIColor = ColorPalette.Black

    private static let staticDarkSecondary: UIColor = ColorPalette.Grey800

    private static let staticDarkTertiary: UIColor = ColorPalette.Grey600

    private static let staticLightPrimary: UIColor = ColorPalette.White

    private static let staticLightSecondary: UIColor = ColorPalette.Grey200

    private static let staticLightTertiary: UIColor = ColorPalette.Grey400

    private static var staticThemePrimary: UIColor = ColorPalette.Blue500

    private static var staticThemeSecondary: UIColor = ColorPalette.Blue700

    private static var dynamicDarkPrimary: UIColor {
        .init { traitCollection in
            switch traitCollection.themeStyle {
            case .light: return staticDarkPrimary
            case .dark: return staticLightPrimary
            }
        }
    }

    private static var dynamicDarkSecondary: UIColor {
        .init { traitCollection in
            switch traitCollection.themeStyle {
            case .light: return staticDarkSecondary
            case .dark: return staticLightSecondary
            }
        }
    }

    private static var dynamicDarkTertiary: UIColor {
        .init { traitCollection in
            switch traitCollection.themeStyle {
            case .light: return staticDarkTertiary
            case .dark: return staticLightTertiary
            }
        }
    }

    private static var dynamicLightPrimary: UIColor {
        .init { traitCollection in
            switch traitCollection.themeStyle {
            case .light: return staticLightPrimary
            case .dark: return staticDarkPrimary
            }
        }
    }

    private static var dynamicLightSecondary: UIColor {
        .init { traitCollection in
            switch traitCollection.themeStyle {
            case .light: return staticLightSecondary
            case .dark: return staticDarkSecondary
            }
        }
    }

    private static var dynamicLightTertiary: UIColor {
        .init { traitCollection in
            switch traitCollection.themeStyle {
            case .light: return staticLightTertiary
            case .dark: return staticDarkTertiary
            }
        }
    }
}

private enum ThemeStyle {
    case light
    case dark
}

private extension UIUserInterfaceStyle {
    var asThemeStyle: ThemeStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .unspecified:
            return .light
        @unknown default:
            return .light
        }
    }
}

private extension UITraitCollection {
    var themeStyle: ThemeStyle {
        userInterfaceStyle.asThemeStyle
    }
}
