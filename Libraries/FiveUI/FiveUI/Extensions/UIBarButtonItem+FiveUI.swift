//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

public extension UIBarButtonItem {

    static func fromSymbol(named symbolName: String, target: AnyObject, action: Selector!) -> UIBarButtonItem {
        SymbolBarButtonItem(symbolName: symbolName, target: target, action: action)
    }

}

private class SymbolBarButtonItem: UIBarButtonItem {

    // this is a really shitty hack lmao

    convenience init(symbolName: String, target: AnyObject, action: Selector!) {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: symbolName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        self.init(customView: button)
        internalButton = button
        super.target = target
        super.action = action
        updateTintColor()
        updateTargetAction()
    }

    override var tintColor: UIColor? {
        didSet {
            updateTintColor()
        }
    }

    override var target: AnyObject? {
        didSet {
            updateTargetAction()
        }
    }

    override var action: Selector? {
        didSet {
            updateTargetAction()
        }
    }

    private var internalButton: UIButton!

    private func updateTintColor() {
        internalButton.tintColor = tintColor
    }

    private func updateTargetAction() {
        internalButton.removeTarget(nil, action: nil, for: .allEvents)
        internalButton.addTarget(target, action: action!, for: .touchUpInside)
    }

}
