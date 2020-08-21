import Foundation

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

protocol APIFuncs: class {

  /// 4
  func sendToPeer(peerID: String, data: Data)

}

protocol APICallbacks: class {

  /// 1
  func tick(ts: Date)
  
  /// 2
  func foundPeer(peerID: String, date: Date)
  /// 3
  func lostPeer(peerID: String, date: Date)

  /// 5
  func didReceiveFromPeer(peerID: String, data: Data)

}

protocol API: APIFuncs & APICallbacks {
  //
}

class APIMan: API {

  var meshController: APICallbacks
  var localNetwork: APIFuncs

  init(meshController: APICallbacks, localNetwork: APIFuncs) {
    self.meshController = meshController
    self.localNetwork = localNetwork
  }

  // funcs

  func tick(ts: Date) {
    meshController.tick(ts: ts)
  }

  func sendToPeer(peerID: String, data: Data) {
    localNetwork.sendToPeer(peerID: peerID, data: data)
  }

  // callbacks

  func foundPeer(peerID: String, date: Date) {
    meshController.foundPeer(peerID: peerID, date: date)
  }

  func lostPeer(peerID: String, date: Date) {
    meshController.lostPeer(peerID: peerID, date: date)
  }

  func didReceiveFromPeer(peerID: String, data: Data) {
    meshController.didReceiveFromPeer(peerID: peerID, data: data)
  }

}
