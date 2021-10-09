import UIKit

final class ReceiptSplitViewController: UIViewController {
    private let dataSource: DataSource
    private let commandProcessor: CommandProcessor
    
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
}
