//
//  BtMan.swift
//  burevestnik
//
//  Created by Marat Saytakov on 12.08.2020.
//

import Foundation
import MultipeerConnectivity

private let kMCSessionServiceType = "burevestnik"

class BtMan: NSObject, APIFuncs {

  func getTime() {
    
  }

  func sendToPeer() {
    #warning("stub")
  }
  
  var api: API

  private var localPeerID: MCPeerID!
  private var browser: MCNearbyServiceBrowser!
  private var advertiser: MCNearbyServiceAdvertiser!
  private var session: MCSession!

  private let pollTiming = TimeInterval(3)

  private var allDiscovered: [BroadMessage] = [] {
    didSet {
//      reloadHandler()
    }
  }

  var allSorted: [BroadMessage] {
    allDiscovered
      .sorted(by: { $0.ti < $1.ti })
  }

  func sendMessage(_ text: String) {
    allDiscovered.append(BroadMessage(text))
    triggerAdvertiseBroadcasting()
  }

  var broadcastBack: [String: String] {

    var res: [String: String] = [:]

    for bbc in allDiscovered {
      res[bbc.ti.timeIntervalSinceReferenceDate.description] = bbc.msg
    }

    return res
  }



  init(api: API) {

//    self.reloadHandler = reloadHandler

//    #if targetEnvironment(simulator)
//    allDiscovered = [BroadMessage("Если кто-то снимает происходящее в Серебрянке - пришлите нам в @BGMnews_bot")]
//    #else
//    allDiscovered = [
//      BroadMessage("Самым безопасным методом борьбы с усатым диктатором будет забастовка. Поэтому общайтесь.",
//                   Date(timeIntervalSinceNow: 1)),
//      BroadMessage("Лукашенко собрал совещание. Понятно из ситуации, что найважнейшими задачами, которые сейчас стоят перед органами власти",
//                   Date(timeIntervalSinceNow: 2)),
//      BroadMessage("Госмедиа заявляют, что Лукашенко начал совещание, где поднял тему сохранения порядка на улицах.",
//                   Date(timeIntervalSinceNow: 3)),
//    ]
//    #endif

    self.api = api

    super.init()

    #warning("declare api funcs")
//    self.api.delegate = self

    localPeerID = MCPeerID(displayName: UIDevice.current.name)

    NSKeyedArchiver(requiringSecureCoding: false).encode(localPeerID, forKey: "root")

    session = MCSession(peer: localPeerID)
    session.delegate = self

    pollTimer = Timer.scheduledTimer(timeInterval: pollTiming,
                                 target: self,
                                 selector: #selector(triggerDiscoveryBrowsing),
                                 userInfo: nil,
                                 repeats: true)
    pollTimer?.tolerance = pollTiming * 0.1

    defer {
      startStopBrowseAdvertise()
    }
  }

  var pollTimer: Timer?

  func startStopBrowseAdvertise() {
    triggerAdvertiseBroadcasting()
    triggerDiscoveryBrowsing()
  }

  func triggerAdvertiseBroadcasting() {
    if advertiser != nil {
      advertiser.stopAdvertisingPeer()
    }

    advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: broadcastBack, serviceType: kMCSessionServiceType)
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
      api.foundPeer()
//      invoke(cmd: .foundPeer, args: .init(peerID: peerID.description, data: nil, time: Date().timeIntervalSince1970))

    case .notConnected:
      api.lostPeer()
//      invoke(cmd: .lostPeer, args: .init(peerID: peerID.description, data: nil, time: Date().timeIntervalSince1970))

    default:
      ()
    }
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    debugPrint(#function, data, peerID)

    api.didReceiveFromPeer()
//    invoke(cmd: .didReceiveFromPeer, args: .init(peerID: peerID.description, data: String(data: data, encoding: .utf8), time: nil))
  }

  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    debugPrint(#function, streamName, peerID)
  }

  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    debugPrint(#function, resourceName, peerID)
  }

  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    debugPrint(#function, resourceName, peerID, localURL)
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




    if let info = info {
      let receivedMessages = BroadMessage.from(dic: info)

      var hasAppend = false

      receivedMessages.forEach { (newMessage) in
        if !allDiscovered.contains(where: { $0.msg == newMessage.msg }) {
          allDiscovered.append(newMessage)
          hasAppend = true
        }
      }

      if hasAppend {
        triggerAdvertiseBroadcasting()
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
