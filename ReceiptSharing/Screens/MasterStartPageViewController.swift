import UIKit

final class MasterStartPageViewController: UIViewController {

    private lazy var photoButton: UIButton = {
        let button = ActionButton()
        button.setTitle("Сфотографировать чек", for: .normal)
        button.addTarget(self, action: #selector(didTouchPhotoButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Разделить счёт"
        view.backgroundColor = .darkBackground
        
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoButton)
        NSLayoutConstraint.activate([
            photoButton.heightAnchor.constraint(equalToConstant: 60),
            photoButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            view.layoutMarginsGuide.rightAnchor.constraint(equalTo: photoButton.rightAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: photoButton.bottomAnchor)
        ])
    }
    
    @objc
    private func didTouchPhotoButton() {
        let receiptPhotoVC = ReceiptPhotoViewController()
        navigationController?.pushViewController(receiptPhotoVC, animated: true)
    }
}
