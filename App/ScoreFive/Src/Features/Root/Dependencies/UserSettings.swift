//
//  File.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 2/21/21.
//

import Combine
import Foundation

/// @mockable
protocol UserSettingsProviding: AnyObject {
    var indexByPlayer: Bool { get }
    var advanceScoreEntryAutomatically: Bool { get }
    var indexByPlayerStream: AnyPublisher<Bool, Never> { get }
    var advanceScoreEntryAutomaticallyStream: AnyPublisher<Bool, Never> { get }
    var warnBeforeDeletingGame: Bool { get }
    var warnBeforeDeletingGameStream: AnyPublisher<Bool, Never> { get }
}

/// @mockable
protocol UserSettingsManaging: UserSettingsProviding {
    var indexByPlayer: Bool { get set }
    var advanceScoreEntryAutomatically: Bool { get set }
    var warnBeforeDeletingGame: Bool { get set }
}

final class UserSettingsManager: UserSettingsManaging {

    @UserSetting(key: "index_by_player")
    var indexByPlayer: Bool = true

    @UserSetting(key: "advance_score_entry_automatically")
    var advanceScoreEntryAutomatically = true

    @UserSetting(key: "warn_before_deleting_game")
    var warnBeforeDeletingGame: Bool = true

    var indexByPlayerStream: AnyPublisher<Bool, Never> {
        $indexByPlayer
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var advanceScoreEntryAutomaticallyStream: AnyPublisher<Bool, Never> {
        $advanceScoreEntryAutomatically
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var warnBeforeDeletingGameStream: AnyPublisher<Bool, Never> {
        $warnBeforeDeletingGame
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

@propertyWrapper
class UserSetting<T> {

    // MARK: - Initializers

    init(wrappedValue value: T, key: String) {
        defaultValue = value
        self.key = key

    }

    // MARK: - PropertyWrapper

    var wrappedValue: T {
        get {
            (UserDefaults.standard.value(forKey: key) as? T) ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
            subject.send(newValue)
        }
    }

    var projectedValue: AnyPublisher<T, Never> {
        subject
            .eraseToAnyPublisher()
    }

    private let key: String
    private let defaultValue: T
    private lazy var subject = CurrentValueSubject<T, Never>(wrappedValue)
}
