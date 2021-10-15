import UIKit

final class ReceiptSplitViewController: UIViewController {
    private let dataSource: DataSource
    private let commandProcessor: CommandProcessor
    private var positionCellModels: [PositionCellModel] = []
    private let collectiomLayout = PositionsCollectionLayout()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectiomLayout
    )
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: creatLayout()
    )
    
    init(dataSource: DataSource = .shared,
         commandProcessor: CommandProcessor) {
        self.dataSource = dataSource
        self.commandProcessor = commandProcessor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "За что вы хотите заплатить?"
        
        view.addSubview(collectionView)
        view.layoutMargins = .init(top: 32, left: 16, bottom: 32, right: 16)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let collectionViewGuide = view.layoutMarginsGuide
        collectionView.topAnchor
            .constraint(equalTo: collectionViewGuide.topAnchor).isActive = true
        collectionView.bottomAnchor
            .constraint(equalTo: collectionViewGuide.bottomAnchor).isActive = true
        collectionView.leadingAnchor
            .constraint(equalTo: collectionViewGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor
            .constraint(equalTo: collectionViewGuide.trailingAnchor).isActive = true
        
        collectionView.dataSource = self
        
        collectionView.register(
            PositionCell.self,
            forCellWithReuseIdentifier: "\(PositionCell.self)"
        )
        
        updatePositions()
        dataSource.onItemsUpdate = { [weak self] in
            self?.updatePositions()
        }
    }
    
    private func updatePositions() {
        positionCellModels = dataSource.items.compactMap {
            makePositionCellModel(for: $0)
        }
        
        collectionView.reloadData()
    }
    
    private func makePositionCellModel(for item: Item) -> PositionCellModel? {
        guard let currentUser = dataSource.currentUser else {
            return nil
        }
        
        let selection = item.selections.first(where: { $0.userId == currentUser.id })
        
        let badges = item.selections.compactMap { selection -> PositionCellModel.Badge? in
            guard selection.userId != currentUser.id,
                  let user = dataSource.users.first(where: { $0.id == selection.userId }),
                let color = UIColor(hex: user.colorHex) else {
                return nil
            }
            
            return .init(counter: selection.count, color: color)
        }
        
        return .init(
            id: item.id,
            title: item.title,
            counter: selection?.count ?? 0,
            badges: badges,
            isEditingAvailable: true,
            isHighlighted: selection != nil
        )
    }
    
    // MARK: - Private
    
    private func creatLayout() -> UICollectionViewCompositionalLayout {
        .init { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            
            switch sectionIndex {
            case 0:
                return self.createListSection()
            default:
                return nil
            }
        }
    }
    
    private func createListSection() -> NSCollectionLayoutSection {
        let cellHeight = CGFloat(64)
        let item = NSCollectionLayoutItem(
            layoutSize:.init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            )
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(cellHeight)),
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}

extension ReceiptSplitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        positionCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = positionCellModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(PositionCell.self)",
            for: indexPath
        ) as! PositionCell
        
        cell.setup(with: cellModel)
        cell.delegate = self
        return cell
    }
}

extension ReceiptSplitViewController: PositionCellDelegate {
    func cellDidPressPlus(_ cell: PositionCell) {
        guard let cellModel = cell.cellModel else { return }
        commandProcessor.process(command: .addSelection(cellModel.id))
    }
    
    func cellDidPressMinus(_ cell: PositionCell) {
        guard let cellModel = cell.cellModel else { return }
        commandProcessor.process(command: .removeSelection(cellModel.id))
    }
}
