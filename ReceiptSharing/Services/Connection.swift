import MultipeerConnectivity

enum Connection {
    static let currentPeer = MCPeerID(displayName: UIDevice.current.name)
    static let serviceType = "ReceiptSharing"
}
