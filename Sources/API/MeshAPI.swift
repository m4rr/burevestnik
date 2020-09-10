import Foundation
import JavaScriptCore

class MeshAPI: NSObject, MeshAPIProtocol & MeshAPIExports {

  var localNetwork: LocalNetwork!

  override init() {
    super.init()

    self.localNetwork = BtMan(meshAPI: self) // WebSocketConn()
  }

  // funcs

  func getMyID() -> NetworkID {
    localNetwork.myID()
  }

  func sendMessage(_ peerID: NetworkID, _ data: NetworkMessage) {
    localNetwork.sendToPeer(id: peerID, data: data)
  }

  func registerPeerAppearedHandler(_ f: JSValue) {
    _peerAppearedHandler = f
  }

  func registerPeerDisappearedHandler(_ f: JSValue) {
    _peerDisappearedHandler = f
  }

  func registerMessageHandler(_ f: JSValue) {
    _messageHandler = f
  }

  func registerTimeTickHandler(_ f: JSValue) {
    _timeTickHandler = f
  }

  // storage

  private var _peerAppearedHandler: JSValue!
  func peerAppearedHandler(_ id: NetworkID) -> Void {
    _peerAppearedHandler.call(withArguments: [id])
  }

  private var _peerDisappearedHandler: JSValue!
  func peerDisappearedHandler(_ id: NetworkID) -> Void {
    _peerDisappearedHandler.call(withArguments: [id])
  }

  private var _messageHandler: JSValue!
  func messageHandler(_ id: NetworkID, _ data: NetworkMessage) {
    _messageHandler.call(withArguments: [id, data])
  }

  private var _timeTickHandler: JSValue!
  func timeTickHandler(_ ts: NetworkTime) {
    _timeTickHandler.call(withArguments: [ts])
  }

}
