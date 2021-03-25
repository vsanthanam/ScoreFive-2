//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation

public extension Notification.Name {

    func asPublisher<T>(object: T?) -> AnyPublisher<Notification, Never> where T: AnyObject {
        NotificationCenter.default.publisher(for: self, object: object).eraseToAnyPublisher()
    }

    func asPublisher(_ object: AnyObject? = nil) -> AnyPublisher<Notification, Never> {
        asPublisher(object: object)
    }

}
