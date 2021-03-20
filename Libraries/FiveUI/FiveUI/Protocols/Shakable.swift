//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

public protocol Shakable: AnyObject {
    func shake()
}

public extension Shakable where Self: UIView {
    func shake() {
        transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
