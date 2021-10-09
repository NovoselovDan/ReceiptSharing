//
//  PositionCell.swift
//  ReceiptSharing
//
//  Created by Daniil Novoselov on 09.10.2021.
//

import UIKit

protocol PositionCellDelegate: AnyObject {
    func cellDidPressPlus(_ cell: PositionCell)
    func cellDidPressMinus(_ cell: PositionCell)
}

struct PositionCellModel {
    
    struct Badge {
        let counter: Int
        let color: UIColor
    }
    
    let title: String
    var counter: Int
    var badges: [Badge]
    var isEditingAvailable: Bool
    var isHighlighted: Bool
}

class PositionCell: UICollectionViewCell {
    
    private enum Colors {
        static let defaultBackground = UIColor(hex: "272730")
        static let highlightedBackground = UIColor(hex: "727387")
    }
    
    private enum Layout {
        static let buttonWidth = CGFloat(42)
    }
    
    weak var delegate: PositionCellDelegate?
    
    private(set) var cellModel: PositionCellModel?
    
    // MARK: - UI properties
    
    private let contentStack = UIStackView()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 23)
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 23)
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private let labelsContainer = UIView()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func setup(with cellModel: PositionCellModel) {
        self.cellModel = cellModel
        
        [minusButton, plusButton].forEach {
            $0.isHidden = !cellModel.isEditingAvailable
        }
        
        counterLabel.text = "\(cellModel.counter)"
        titleLabel.text = cellModel.title
        
        contentView.backgroundColor = cellModel.isHighlighted ? Colors.highlightedBackground : Colors.defaultBackground
    }
    
    // MARK: - Private
    
    func commonInit() {
        contentView.backgroundColor = Colors.defaultBackground
        contentView.layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentStack.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: contentStack.bottomAnchor),
            contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: contentStack.rightAnchor)
        ])
        
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.widthAnchor.constraint(equalToConstant: Layout.buttonWidth).isActive = true
        contentStack.addArrangedSubview(minusButton)
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        [counterLabel, titleLabel].forEach {
            labelsContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            counterLabel.leftAnchor.constraint(equalTo: labelsContainer.leftAnchor),
            counterLabel.centerYAnchor.constraint(equalTo: labelsContainer.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: counterLabel.rightAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: labelsContainer.centerYAnchor),
            labelsContainer.rightAnchor.constraint(equalTo: titleLabel.rightAnchor)
        ])
        contentStack.addArrangedSubview(labelsContainer)
        
        contentStack.addArrangedSubview(plusButton)
        plusButton.widthAnchor.constraint(equalToConstant: Layout.buttonWidth).isActive = true
    }
    
    @objc
    private func didTapButton(_ button: UIButton) {
        guard let delegate = delegate else { return }
        switch button {
        case minusButton:
            delegate.cellDidPressMinus(self)
        case plusButton:
            delegate.cellDidPressPlus(self)
        default:
            return
        }
    }
    
}

// 272730
