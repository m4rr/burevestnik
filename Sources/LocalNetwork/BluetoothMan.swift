import Foundation
import MultipeerConnectivity

private let kMCSessionService = "burevestnik"

class BtMan: NSObject {
  
  var api: MeshAPI! {
    didSet {
      startStopBrowseAdvertise()
    }
  }

  private let localPeerID: MCPeerID = MCPeerID(displayName: kThisDeviceName)

  private var session: MCSession!
  private var browser: MCNearbyServiceBrowser!
  private var advertiser: MCNearbyServiceAdvertiser!

  private var peers: [NetworkID: MCPeerID] = [:]

  func startStopBrowseAdvertise() {
    session = MCSession(peer: localPeerID)

    triggerAdvertiseBroadcasting()
    triggerDiscoveryBrowsing()
  }

  func archivePeerID(_ pid: MCPeerID) -> Data? {
    try? NSKeyedArchiver.archivedData(withRootObject: pid, requiringSecureCoding: true)
  }

  func unarchivePeerID(_ pid: Data) -> MCPeerID? {
    try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: pid)
  }

  func triggerAdvertiseBroadcasting() {

    // cancel if not nil
    advertiser?.stopAdvertisingPeer()

    advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: kMCSessionService)
    advertiser.delegate = self

    advertiser.startAdvertisingPeer()
  }

  @objc func triggerDiscoveryBrowsing() {

    // cancel if not nil
    browser?.stopBrowsingForPeers()

    browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: kMCSessionService)
    browser.delegate = self

    browser.startBrowsingForPeers()
  }
}

extension BtMan: MCSessionDelegate {

  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    debugPrint(#function, peerID, state.rawValue)

    switch state {
    case .connected:
      api.foundPeer(peerID: peerID.displayName)

    case .notConnected:
      api.lostPeer(peerID: peerID.displayName)

    default:
      ()
    }
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    debugPrint(#function, data, peerID)

    api.didReceiveFromPeer(peerID: peerID.displayName, data: data)
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

//  func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
//    debugPrint(#function, peerID, certificate ?? "<no certificate>")
//
//    if certificate != nil { certificateHandler(true) }
//  }
}

extension BtMan: MCNearbyServiceBrowserDelegate {

  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    debugPrint(#function, peerID, info ?? "<no info>")

    if peerID.displayName == self.localPeerID.displayName {
      return
    }

    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 5)
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    debugPrint(#function, peerID)
  }
}

extension BtMan: MCNearbyServiceAdvertiserDelegate {

  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    invitationHandler(true, session)
  }
}

extension BtMan {

  func sessionSend(to peerID: String, data str: String) {
    if let data = str.data, let toPeer = peers[peerID] { // Do not attempt to construct
      try? session.send(data,                            // a peer ID object
                        toPeers: [toPeer],               // for a nonlocal peer
                        with: .reliable)
    }
  }
}

extension BtMan: APIFuncs {

  func myID() -> NetworkID {
    kThisDeviceName
  }

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
    sessionSend(to: peerID, data: data)
  }
}
