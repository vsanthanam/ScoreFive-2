//
// ScoreFive
// Varun Santhanam
//

import Foundation
import SnapKit
import UIKit

public enum Symbol {

    open class View: BaseView {

        public init(symbolName: String, pointSize: CGFloat = 17.0) {
            self.symbolName = symbolName
            self.pointSize = pointSize
            super.init()
            isUserInteractionEnabled = false
            setUp()
        }

        open var symbolName: String {
            didSet {
                refreshImage()
            }
        }

        open var pointSize: CGFloat {
            didSet {
                refreshImage()
                invalidateIntrinsicContentSize()
            }
        }

        open var symbolColor: UIColor? {
            get { imageView.tintColor }
            set { imageView.tintColor = newValue }
        }

        // MARK: - UIView

        override open var intrinsicContentSize: CGSize {
            .init(width: pointSize, height: pointSize)
        }

        // MARK: - Private

        private let imageView = UIImageView()

        private var symbolConfiguration: UIImage.SymbolConfiguration {
            UIImage.SymbolConfiguration(pointSize: pointSize)
        }

        private var image: UIImage? {
            let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
            return image
        }

        private func setUp() {
            backgroundColor = .transparent
            imageView.backgroundColor = .transparent
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make
                    .edges
                    .equalToSuperview()
            }
            refreshImage()
        }

        private func refreshImage() {
            imageView.preferredSymbolConfiguration = symbolConfiguration
            imageView.image = image
        }
    }

    open class Button: TappableControl {

        // MARK: - Initializers

        public init(symbolName: String, pointSize: CGFloat = 17.0) {
            self.symbolName = symbolName
            symbolView = .init(symbolName: symbolName, pointSize: pointSize)
            super.init()
            setUp()
        }

        // MARK: - API

        open var symbolName: String {
            didSet {
                refreshImage()
            }
        }

        open var highlightedSymbolName: String? {
            didSet {
                refreshImage()
            }
        }

        open var pointSize: CGFloat {
            get {
                symbolView.pointSize
            }
            set {
                symbolView.pointSize = newValue
            }
        }

        open var symbolColor: UIColor = .contentPrimary {
            didSet {
                refreshImage()
            }
        }

        open var highlightedSymbolColor: UIColor? {
            didSet {
                refreshImage()
            }
        }

        open var activeColor: UIColor = .transparent {
            didSet {
                refreshImage()
            }
        }

        open var highlightedActiveColor: UIColor? {
            didSet {
                refreshImage()
            }
        }

        // MARK: - UIControl

        override open var isHighlighted: Bool {
            didSet {
                refreshImage()
            }
        }

        // MARK: - UIView

        override open var intrinsicContentSize: CGSize {
            .init(width: pointSize, height: pointSize)
        }

        // MARK: - Private

        private let symbolView: Symbol.View

        private var symbolConfiguration: UIImage.SymbolConfiguration {
            UIImage.SymbolConfiguration(pointSize: pointSize)
        }

        private func setUp() {
            addSubview(symbolView)
            symbolView.snp.makeConstraints { make in
                make
                    .edges
                    .equalToSuperview()
            }
            refreshImage()
        }

        private func refreshImage() {
            if isHighlighted {
                backgroundColor = highlightedActiveColor ?? activeColor
                symbolView.symbolColor = highlightedSymbolColor ?? symbolColor
                symbolView.symbolName = highlightedSymbolName ?? symbolName
            } else {
                backgroundColor = activeColor
                symbolView.symbolColor = symbolColor
                symbolView.symbolName = symbolName
            }
        }
    }
}
