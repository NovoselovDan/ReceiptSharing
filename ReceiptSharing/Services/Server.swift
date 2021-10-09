import MultipeerConnectivity

final class Server: NSObject {
    static let shared = Server()
    
    private let colors: [String] = [
        "#FF0000",
        "#00FF00",
        "#0000FF"
    ]
    
    private var users: [MCPeerID: User] = [:]
    private var items: [Item] = [
        .init(title: "Пицца 4 сыра", price: 300),
        .init(title: "Картофель по деревенски", price: 100),
        .init(title: "Крем-суп грибной", price: 200),
        .init(title: "Пивко светленькое", price: 200),
        .init(title: "Пивко темненькое", price: 200)
    ]
    
    private let session = MCSession(
        peer: Connection.currentPeer,
        securityIdentity: nil,
        encryptionPreference: .none
    )
    private let advertiser = MCNearbyServiceAdvertiser(
        peer: Connection.currentPeer,
        discoveryInfo: nil,
        serviceType: Connection.serviceType
    )
    
    private let dataSource: DataSource
    
    init(dataSource: DataSource = .shared) {
        self.dataSource = dataSource
    }
    
    func start() {
        session.delegate = self
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    private func handle(command: Command, peerID: MCPeerID) {
        switch command {
        case .newSession(let userName):
            addUser(name: userName, peerID: peerID)
        case .addSelection(let itemId):
            addItemSelection(id: itemId, peerID: peerID)
        case .removeSelection(let itemId):
            removeItemSelection(id: itemId, peerID: peerID)
        case .complete:
            complete(peerID: peerID)
        }
    }
    
    private func addUser(name: String, peerID: MCPeerID) {
        let newUser = User(
            name: name,
            colorHex: colors[users.count],
            finished: false
        )
        
        users[peerID] = newUser
        
        let initialData = InitialData(
            currentUser: newUser,
            users: Array(users.values),
            items: items
        )
        send(event: .initial(initialData), peers: [peerID])
        
        sendUpdateUsersEvent()
    }
    
    private func addItemSelection(id: ItemId, peerID: MCPeerID) {
        guard let itemIndex = items.firstIndex(where: { $0.id == id }),
            let user = users[peerID] else {
            return
        }
        
        if let selectionIndex = items[itemIndex].selections
            .firstIndex(where: { $0.userId == user.id }) {
            items[itemIndex].selections[selectionIndex].count += 1
        } else {
            items[itemIndex].selections.append(.init(userId: user.id, count: 0))
        }
    }
    
    private func removeItemSelection(id: ItemId, peerID: MCPeerID) {
        guard let itemIndex = items.firstIndex(where: { $0.id == id }),
            let user = users[peerID],
              let selectionIndex = items[itemIndex].selections
                .firstIndex(where: { $0.userId == user.id }) else {
            return
        }
        
        if items[itemIndex].selections[selectionIndex].count > 1 {
            items[itemIndex].selections[selectionIndex].count -= 1
        } else {
            items[itemIndex].selections.remove(at: selectionIndex)
        }
    }
    
    private func complete(peerID: MCPeerID) {
        users[peerID]?.finished = true
        sendUpdateUsersEvent()
    }
    
    private func removeUser(peerID: MCPeerID) {
        users[peerID] = nil
        sendUpdateUsersEvent()
    }
    
    private func sendToAllPeers(event: Event) {
        send(event: event, peers: session.connectedPeers)
        dataSource.process(event: event)
    }
    
    private func send(event: Event, peers: [MCPeerID]) {
        if peers.contains(Connection.currentPeer) {
            dataSource.process(event: event)
        } else {
            do {
                let data = try JSONEncoder().encode(event)
                try session.send(data, toPeers: peers, with: .reliable)
            } catch {
                print("Event hasn't been sent")
            }
        }
    }
    
    private func sendUpdateUsersEvent() {
        sendToAllPeers(event: .updateUsers(Array(users.values)))
    }
    
    private func sendUpdateItemsEvent() {
        sendToAllPeers(event: .updateItems(items))
    }
}

extension Server: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

extension Server: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                self.removeUser(peerID: peerID)
            default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            do {
                let command = try JSONDecoder().decode(Command.self, from: data)
                self.handle(command: command, peerID: peerID)
            } catch {
                print("Command hasn't been processed")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension Server: CommandProcessor {
    func process(command: Command) {
        handle(command: command, peerID: Connection.currentPeer)
    }
}
