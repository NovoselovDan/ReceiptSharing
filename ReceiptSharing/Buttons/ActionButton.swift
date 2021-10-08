//
//  ActionButton.swift
//  ReceiptSharing
//
//  Created by Daniil Novoselov on 09.10.2021.
//

import UIKit

class ActionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    // MARK: - Private methods
    
    private func commonInit() {
        self.backgroundColor = .init(hex: "272730")
        layer.cornerCurve = .circular
        layer.cornerRadius = 8
        layer.masksToBounds = true
    
        titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        setTitleColor(.init(hex: "FDFDFD"), for: .normal)
    }
}
