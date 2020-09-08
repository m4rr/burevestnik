import Foundation
import MultipeerConnectivity

private let kMCSessionService = "burevestnik"

class BtMan: NSObject {

  private let started = Date()
  private lazy var timer = Timer
    .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      if let ts = self?.started.timeIntervalSinceNow {
        self?.meshAPI.timeTickHandler(-ts)
      }
    }

  /// Starts multipeer session when assigned.
  weak var meshAPI: MeshAPI! {
    didSet {
      startSession()

      _ = timer.description
    }
  }

  init(meshAPI: MeshAPI) {
    self.meshAPI = meshAPI
  }

  deinit {
    
  }

  private let localPeerID: MCPeerID = MCPeerID(displayName: kThisDeviceName)

  private lazy var session: MCSession! = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
  private var browser: MCNearbyServiceBrowser!
  private var advertiser: MCNearbyServiceAdvertiser!

  private var peers: [NetworkID: MCPeerID] = [:]

  private func startSession() {
    session.delegate = self

    startAdvertising()
    startBrowsing()
  }

  func archivePeerID(_ pid: MCPeerID) -> Data? {
    try? NSKeyedArchiver.archivedData(withRootObject: pid, requiringSecureCoding: true)
  }

  func unarchivePeerID(_ pid: Data) -> MCPeerID? {
    try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: pid)
  }

  private func stopAdvertising() {

    // cancel if not nil
    advertiser?.stopAdvertisingPeer()
  }

  private func startAdvertising() {

    if advertiser == nil {
      advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: ["me": localPeerID.displayName], serviceType: kMCSessionService)
      advertiser.delegate = self
    }

    advertiser.startAdvertisingPeer()
  }

  private func stopDiscoveryBrowsing() {

    // cancel if not nil
    browser?.stopBrowsingForPeers()
  }

  private func startBrowsing() {

    if browser == nil {
      browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: kMCSessionService)
      browser.delegate = self
    }

    browser.startBrowsingForPeers()
  }

}

extension BtMan: MCSessionDelegate {

  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    debugPrint(#function, peerID, state.rawValue)

    switch state {
    case .connected:
      peers[peerID.displayName] = peerID
      meshAPI.peerAppearedHandler(peerID.displayName)

    case .notConnected:
      meshAPI.peerDisappearedHandler(peerID.displayName)
      peers[peerID.displayName] = nil

    default:
      ()
    }
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    debugPrint(#function, data, peerID)

    if let str = data.string {
      meshAPI.messageHandler(peerID.displayName, str)
    } else {
      assertionFailure("no data")
    }
  }

  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    debugPrint(#function, streamName, peerID)
  }

  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    debugPrint(#function, resourceName, peerID)
  }

  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    debugPrint(#function, resourceName, peerID, localURL ?? "---")
  }

  func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
    debugPrint(#function, peerID, certificate ?? "<no certificate>")

    certificateHandler(true)
  }
}

extension BtMan: MCNearbyServiceBrowserDelegate {

  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    debugPrint(#function, peerID, info ?? "<no info>")

    if peerID.displayName == self.localPeerID.displayName {
      return
    }

    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    debugPrint(#function, peerID)
  }
}

extension BtMan: MCNearbyServiceAdvertiserDelegate {

  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    debugPrint(context?.debugDescription ?? "--no invite data")

    invitationHandler(true, session)

//    stopAdvertising()
  }
}

extension BtMan {

  func sessionSend(to peerID: String, data str: String) {
    // Do not attempt to construct a peer ID object for a nonlocal peer
    guard let data = str.data, let toPeer = peers[peerID] else {
      return debugPrint("no---err")
    }

    do {
      try session.send(data, toPeers: [toPeer], with: .reliable)
    } catch let err {
      debugPrint(err)
    }
  }

}

extension BtMan: LocalNetwork {
  
  func getMyID() -> NetworkID {
    kThisDeviceName
  }

  func sendMessage(peerID: NetworkID, data: NetworkMessage) {
    sessionSend(to: peerID, data: data)
  }

}
