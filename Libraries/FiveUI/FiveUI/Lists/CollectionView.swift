//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

/// A protocol describing a cell content configuration that can be initialized without parameters. For every cell, create a struct that conforms to this type.
public protocol CellContentConfiguration: UIContentConfiguration {
    init()
}

/// The content view of a cell, specialized against its matching content configuration struct.
open class CellContentView<T>: UIView, UIContentView where T: CellContentConfiguration {

    // MARK: - Initializers

    public init(configuration: T) {
        specializedConfiguration = configuration
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Don't Use Interface Builder 😡")
    }

    // MARK: - API

    open private(set) var specializedConfiguration: T

    open func apply(configuration: T) {
        fatalError("Abstract Method Not Implemented 😡")
    }

    // MARK: - UIContentView

    public var configuration: UIContentConfiguration {
        get { specializedConfiguration }
        set {
            guard let config = newValue as? T else {
                assertionFailure("Invalid Config Type")
                return
            }
            specializedConfiguration = config
            apply(configuration: specializedConfiguration)
        }
    }
}

open class ListCell<ContentConfiguration, ContentView>: CollectionViewListCell where ContentConfiguration: CellContentConfiguration, ContentView: CellContentView<ContentConfiguration> {
    public class func newConfiguration() -> ContentConfiguration {
        .init()
    }
}

open class CollectionViewListCell: UICollectionViewListCell {
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Don't Use Interface Builder 😡")
    }
}

open class Cell<ContentConfiguration, ContentView>: CollectionViewCell where ContentConfiguration: CellContentConfiguration, ContentView: CellContentView<ContentConfiguration> {
    public class func newConfiguration() -> ContentConfiguration {
        .init()
    }
}

open class CollectionViewCell: UICollectionViewCell {
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Don't Use Interface Builder 😡")
    }
}

open class TableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Don't Use Interface Builder 😡")
    }
}

open class TableCell<ContentConfiguration, ContentView>: TableViewCell where ContentConfiguration: CellContentConfiguration, ContentView: CellContentView<ContentConfiguration> {

    public class func newConfiguration() -> ContentConfiguration {
        .init()
    }

}
