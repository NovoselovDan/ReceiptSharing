import UIKit

final class ReceiptSplitViewController: UIViewController {
    private let dataSource: DataSource
    private let commandProcessor: CommandProcessor
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: creatLayout()
    )
    
    init(dataSource: DataSource = .shared,
         commandProcessor: CommandProcessor = FakeCommandProcessor()) {
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
