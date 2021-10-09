import MultipeerConnectivity

final class Client: NSObject {
    static let shared = Client()
    
    private let session = MCSession(
        peer: Connection.currentPeer,
        securityIdentity: nil,
        encryptionPreference: .none
    )
    
    private let browser = MCNearbyServiceBrowser(
        peer: Connection.currentPeer,
        serviceType: Connection.serviceType
    )
    
    private var cachedCommands: [Command] = []
    
    private let dataSource: DataSource
    
    private var serverPeer: MCPeerID?
    
    init(dataSource: DataSource = .shared) {
        self.dataSource = dataSource
    }
    
    func start() {
        session.delegate = self
        startBrowsing()
    }
    
    func send(command: Command) {
        guard let serverPeer = serverPeer else {
            cachedCommands.append(command)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(command)
            try session.send(data, toPeers: [serverPeer], with: .reliable)
        } catch {
            print("Command hasn't been sent")
        }
    }
    
    private func startBrowsing() {
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    private func stopBrowsing() {
        browser.delegate = nil
        browser.stopBrowsingForPeers()
    }
}

extension Client: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .notConnected:
                self.startBrowsing()
            case .connected:
                self.serverPeer = peerID
                self.stopBrowsing()
                self.cachedCommands.forEach { self.send(command: $0) }
                self.cachedCommands.removeAll()
            default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            guard peerID == self.serverPeer else { return }
            
            do {
                let event = try JSONDecoder().decode(Event.self, from: data)
                self.dataSource.process(event: event)
            } catch {
                print("Event hasn't been processed")
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

extension Client: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }
}

extension Client: CommandProcessor {
    func process(command: Command) {
        send(command: command)
    }
}
