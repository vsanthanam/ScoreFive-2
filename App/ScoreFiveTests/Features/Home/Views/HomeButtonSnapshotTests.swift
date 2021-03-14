//
//  HomeButtonSnapshotTests.swift
//  ScoreFiveTests
//
//  Created by Varun Santhanam on 2/6/21.
//

import FBSnapshotTestCase
@testable import ScoreFive
import SnapKit

final class HomeButtonSnapshotTests: SnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func test_home_button() {
        let canvas = UIView(frame: .init(origin: .init(x: 0.0,
                                                       y: 0.0),
                                         size: .init(width: 300.0,
                                                     height: 300.0)))
        let button = HomeButton(title: "Home Button")
        canvas.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16.0)
            make.center.equalToSuperview()
        }
        FBSnapshotVerifyView(canvas)
    }

    func test_home_button_highlighted() {
        let canvas = UIView(frame: .init(origin: .init(x: 0.0,
                                                       y: 0.0),
                                         size: .init(width: 300.0,
                                                     height: 300.0)))
        let button = HomeButton(title: "Home Button")
        canvas.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16.0)
            make.center.equalToSuperview()
        }
        button.isHighlighted = true
        FBSnapshotVerifyView(canvas)
    }
}
