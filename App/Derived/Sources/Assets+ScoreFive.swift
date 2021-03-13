// swiftlint:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#elseif os(tvOS) || os(watchOS)
    import UIKit
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum ScoreFiveAsset {
    public static let accentColor = ScoreFiveColors(name: "AccentColor")
    public static let cardIcon = ScoreFiveImages(name: "CardIcon")
}

// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ScoreFiveColors {
    public fileprivate(set) var name: String

    #if os(macOS)
        public typealias Color = NSColor
    #elseif os(iOS) || os(tvOS) || os(watchOS)
        public typealias Color = UIColor
    #endif

    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    public private(set) lazy var color: Color = {
        guard let color = Color(asset: self) else {
            fatalError("Unable to load color asset named \(name).")
        }
        return color
    }()

    fileprivate init(name: String) {
        self.name = name
    }
}

public extension ScoreFiveColors.Color {
    @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
    convenience init?(asset: ScoreFiveColors) {
        let bundle = ScoreFiveResources.bundle
        #if os(iOS) || os(tvOS)
            self.init(named: asset.name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
            self.init(named: NSColor.Name(asset.name), bundle: bundle)
        #elseif os(watchOS)
            self.init(named: asset.name)
        #endif
    }
}

public struct ScoreFiveImages {
    public fileprivate(set) var name: String

    #if os(macOS)
        public typealias Image = NSImage
    #elseif os(iOS) || os(tvOS) || os(watchOS)
        public typealias Image = UIImage
    #endif

    public var image: Image {
        let bundle = ScoreFiveResources.bundle
        #if os(iOS) || os(tvOS)
            let image = Image(named: name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
            let image = bundle.image(forResource: NSImage.Name(name))
        #elseif os(watchOS)
            let image = Image(named: name)
        #endif
        guard let result = image else {
            fatalError("Unable to load image asset named \(name).")
        }
        return result
    }
}

public extension ScoreFiveImages.Image {
    @available(macOS, deprecated,
               message: "This initializer is unsafe on macOS, please use the ScoreFiveImages.image property")
    convenience init?(asset: ScoreFiveImages) {
        #if os(iOS) || os(tvOS)
            let bundle = ScoreFiveResources.bundle
            self.init(named: asset.name, in: bundle, compatibleWith: nil)
        #elseif os(macOS)
            self.init(named: NSImage.Name(asset.name))
        #elseif os(watchOS)
            self.init(named: asset.name)
        #endif
    }
}