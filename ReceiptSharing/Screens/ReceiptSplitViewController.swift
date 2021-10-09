import UIKit

final class ReceiptSplitViewController: UIViewController {
    private let dataSource: DataSource
    private let commandProcessor: CommandProcessor
    private var positionViewModels: [PositionCellModel] = []
    
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
        
        title = "За что вы хотите заплатить?"
        
        dataSource.onItemsUpdate = { [weak self] in
            self?.updatePositions()
        }
    }
    
    private func updatePositions() {
        positionViewModels = dataSource.items.compactMap {
            makePositionViewModel(for: $0)
        }
        
        // Reload collection view
    }
    
    private func makePositionViewModel(for item: Item) -> PositionCellModel? {
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
            title: item.title,
            counter: selection?.count ?? 0,
            badges: badges,
            isEditingAvailable: true,
            isHighlighted: false
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
