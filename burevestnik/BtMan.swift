//
//  BtMan.swift
//  burevestnik
//
//  Created by Marat on 12.08.2020.
//  Copyright © 2020 Marat. All rights reserved.
//

import Foundation
import MultipeerConnectivity

private let kMCSessionServiceType = "burevestnik"

class BtMan: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

  var peer: MCPeerID!
  var browser: MCNearbyServiceBrowser!
  var advertiser: MCNearbyServiceAdvertiser!
  var session: MCSession!

  private var allDiscovered: [BroadMessage] = [] {
    didSet {
      reloadHandler()
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

  var reloadHandler: () -> Void

  init(reloadHandler: @escaping () -> Void) {
    self.reloadHandler = reloadHandler

    #if targetEnvironment(simulator)
    allDiscovered = [BroadMessage("Если кто-то снимает происходящее в Серебрянке - пришлите нам в @BGMnews_bot")]
    #else
    allDiscovered = [
      BroadMessage("Самым безопасным методом борьбы с усатым диктатором будет забастовка. Поэтому общайтесь.",
                   Date(timeIntervalSinceNow: 1)),
      BroadMessage("Лукашенко собрал совещание. Понятно из ситуации, что найважнейшими задачами, которые сейчас стоят перед органами власти",
                   Date(timeIntervalSinceNow: 2)),
      BroadMessage("Госмедиа заявляют, что Лукашенко начал совещание, где поднял тему сохранения порядка на улицах.",
                   Date(timeIntervalSinceNow: 3)),
    ]
    #endif


    super.init()

    peer = MCPeerID(displayName: UIDevice.current.name)

    session = MCSession(peer: peer)
    session.delegate = self


    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(triggerDiscoveryBrowsing), userInfo: nil, repeats: true)
    timer?.tolerance = 5 * 0.1

    defer {
      startStopBrowseAdvertise()
    }
  }

  var timer: Timer?

  func startStopBrowseAdvertise() {
    triggerAdvertiseBroadcasting()
    triggerDiscoveryBrowsing()
  }

  func triggerAdvertiseBroadcasting() {
    if advertiser != nil {
      advertiser.stopAdvertisingPeer()
    }

    advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: broadcastBack, serviceType: kMCSessionServiceType)
    advertiser.delegate = self

    advertiser.startAdvertisingPeer()
  }

  @objc func triggerDiscoveryBrowsing() {
    if browser != nil {
      browser.stopBrowsingForPeers()
    }

    browser = MCNearbyServiceBrowser(peer: peer, serviceType: kMCSessionServiceType)
    browser.delegate = self

    browser.startBrowsingForPeers()
  }

  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    debugPrint(#function, state)
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    debugPrint(#function, data, peerID)
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

  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    debugPrint(#function, peerID, info)

    if peerID.displayName == self.peer.displayName {
      return
    }

    if let info = info {
      let receivedMessages = BroadMessage.from(dic: info)

      receivedMessages.forEach { (newMessage) in
        if !allDiscovered.contains(where: { $0.msg == newMessage.msg }) {
          allDiscovered.append(newMessage)
        }
      }
    }
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    debugPrint(#function, peerID)
  }

  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    debugPrint(#function, peerID)
  }

}
