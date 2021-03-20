//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

public enum ColorPalette {

    // MARK: - Basics

    public static var White: UIColor = .white

    public static var Black: UIColor = .black

    public static var Transparent: UIColor = .clear

    // MARK: - Grey

    public static var Grey50: UIColor = .init(0xFAFAFA)

    public static var Grey100: UIColor = .init(0xF5F5F5)

    public static var Grey200: UIColor = .init(0xEEEEEE)

    public static var Grey300: UIColor = .init(0xE0E0E0)

    public static var Grey400: UIColor = .init(0xBDBDBD)

    public static var Grey500: UIColor = .init(0x9E9E9E)

    public static var Grey600: UIColor = .init(0x757575)

    public static var Grey700: UIColor = .init(0x616161)

    public static var Grey800: UIColor = .init(0x424242)

    public static var Grey900: UIColor = .init(0x212121)

    // MARK: - Green

    public static var Green50: UIColor = .init(0xE8F5E9)

    public static var Green100: UIColor = .init(0xC8E6C9)

    public static var Green200: UIColor = .init(0xA5D6A7)

    public static var Green300: UIColor = .init(0x81C784)

    public static var Green400: UIColor = .init(0x66BB6A)

    public static var Green500: UIColor = .init(0x4CAF50)

    public static var Green600: UIColor = .init(0x43A047)

    public static var Green700: UIColor = .init(0x388E3C)

    public static var Green800: UIColor = .init(0x2E7D32)

    public static var Green900: UIColor = .init(0x1B5E20)

    // MARK: - Blue

    public static var Blue50: UIColor = .init(0xE3F2FD)

    public static var Blue100: UIColor = .init(0xBBDEFB)

    public static var Blue200: UIColor = .init(0x90CAF9)

    public static var Blue300: UIColor = .init(0x64B5F6)

    public static var Blue400: UIColor = .init(0x42A5F5)

    public static var Blue500: UIColor = .init(0x2196F3)

    public static var Blue600: UIColor = .init(0x1E88E5)

    public static var Blue700: UIColor = .init(0x1976D2)

    public static var Blue800: UIColor = .init(0x1565C0)

    public static var Blue900: UIColor = .init(0x0D47A1)

    // MARK: - Amber

    public static var Amber50: UIColor = .init(0xFFF8E1)

    public static var Amber100: UIColor = .init(0xFFECB3)

    public static var Amber200: UIColor = .init(0xFFE082)

    public static var Amber300: UIColor = .init(0xFFD54F)

    public static var Amber400: UIColor = .init(0xFFCA28)

    public static var Amber500: UIColor = .init(0xFFC107)

    public static var Amber600: UIColor = .init(0xFFB300)

    public static var Amber700: UIColor = .init(0xFFA000)

    public static var Amber800: UIColor = .init(0xFF8F00)

    public static var Amber900: UIColor = .init(0xFF6F00)

    // MARK: - Red

    public static var Red50: UIColor = .init(0xFFEBEE)

    public static var Red100: UIColor = .init(0xFFCDD2)

    public static var Red200: UIColor = .init(0xEF9A9A)

    public static var Red300: UIColor = .init(0xE57373)

    public static var Red400: UIColor = .init(0xEF5350)

    public static var Red500: UIColor = .init(0xF44336)

    public static var Red600: UIColor = .init(0xE53935)

    public static var Red700: UIColor = .init(0xD32F2F)

    public static var Red800: UIColor = .init(0xC62828)

    public static var Red900: UIColor = .init(0xB71C1C)
}

private extension UIColor {
    convenience init(_ hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
