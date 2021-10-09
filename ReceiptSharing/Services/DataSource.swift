final class DataSource {
    static let shared = DataSource()
    
    private(set) var users: [User] = []
    private(set) var items: [Item] = []
    private(set) var currentUser: User?
    
    var onUsersUpdate: (() -> Void)?
    var onItemsUpdate: (() -> Void)?
    
    func process(event: Event) {
        switch event {
        case .initial(let initialData):
            users = initialData.users
            items = initialData.items
            currentUser = initialData.currentUser
            onUsersUpdate?()
            onItemsUpdate?()
        case .updateItems(let items):
            self.items = items
            onItemsUpdate?()
        case .updateUsers(let users):
            self.users = users
            onUsersUpdate?()
        }
    }
}
