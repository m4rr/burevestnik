import Foundation
import MultipeerConnectivity

private let kMCSessionServiceType = "burevestnik"

class BtMan: NSObject {
  
  var api: MeshAPI! {
    didSet {
      localPeerID = MCPeerID(displayName: UIDevice.current.name)
      //    NSKeyedArchiver(requiringSecureCoding: false).encode(localPeerID, forKey: "root")

      session = MCSession(peer: localPeerID)
      session.delegate = self

      startStopBrowseAdvertise()
    }
  }

  private var localPeerID: MCPeerID!
  private var browser: MCNearbyServiceBrowser!
  private var advertiser: MCNearbyServiceAdvertiser!
  private var session: MCSession!

  var pollTimer: Timer?

  func startStopBrowseAdvertise() {
    triggerAdvertiseBroadcasting()
    triggerDiscoveryBrowsing()
  }

  func triggerAdvertiseBroadcasting() {
    if advertiser != nil {
      advertiser.stopAdvertisingPeer()
    }

    advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: kMCSessionServiceType)
    advertiser.delegate = self

    advertiser.startAdvertisingPeer()
  }

  @objc func triggerDiscoveryBrowsing() {
    if browser != nil {
      browser.stopBrowsingForPeers()
    }

    browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: kMCSessionServiceType)
    browser.delegate = self

    browser.startBrowsingForPeers()
  }

}

extension BtMan: MCSessionDelegate {

  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    debugPrint(#function, state)

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
//    debugPrint(#function, resourceName, peerID, localURL)
  }

}

extension BtMan: MCNearbyServiceBrowserDelegate {

  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    debugPrint(#function, peerID, info)

    if peerID.displayName == self.localPeerID.displayName {
      return
    }

    session.nearbyConnectionData(forPeer: peerID) { (data, error) in
      if let data = data {
        self.session.connectPeer(peerID, withNearbyConnectionData: data)
      } else if let error = error {
        debugPrint(error)
      }
    }
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    debugPrint(#function, peerID)
  }

}

extension BtMan: MCNearbyServiceAdvertiserDelegate {

  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    debugPrint(#function, peerID)
  }
}

extension BtMan {

  func sessionSend(to peerID: String, data str: String) {
    if let data = str.data(using: .utf8) {
      try? session.send(data,
                        toPeers: [MCPeerID(displayName: peerID)],
                        with: .reliable)
    }
  }

}

extension BtMan: APIFuncs {

  func myID() -> NetworkID {
    UIDevice.current.name
  }

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
//    guard let data = data.string else { return }
    sessionSend(to: peerID, data: data)
  }

}
