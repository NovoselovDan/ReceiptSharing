import UIKit

final class PositionsCollectionLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
            
        itemSize = .init(
            width: collectionView.bounds.width,
            height: 63
        )
    }
}
