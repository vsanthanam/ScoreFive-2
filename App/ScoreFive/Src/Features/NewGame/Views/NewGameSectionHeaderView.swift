//
//  NewGameSectionHeader.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 1/3/21.
//

import Foundation
import UIKit

final class NewGameSectionHeaderView: UICollectionReusableView {
    
    var title: String? {
        get { label.text }
        set { label.text = newValue?.uppercased() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .transparent
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label = UILabel()
    
    private func setUp() {
        addSubview(label)
        label.font = .systemFont(ofSize: 15.0)
        label.textColor = .contentTertiary
        label.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalToSuperview()
            make
                .top
                .bottom
                .equalToSuperview()
                .inset(6.0)
        }
    }
}
    
    
