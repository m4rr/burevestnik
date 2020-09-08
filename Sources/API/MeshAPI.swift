import Foundation

class MeshAPI: NSObject, MeshAPIProtocol {

  var localNetwork: LocalNetwork!

  override init() {
    super.init()

    self.localNetwork = BtMan(meshAPI: self) // WebSocketConn()
  }

  // funcs

  func getMyID() -> NetworkID {
    localNetwork.getMyID()
  }

  func sendMessage(peerID: NetworkID, data: NetworkMessage) {
    localNetwork.sendMessage(peerID: peerID, data: data)
  }

  // storage

  private(set) var peerAppearedHandler: (NetworkID) -> Void = { _ in
    debugPrint("PeerAppearedHandler not imp") }

  private(set) var peerDisappearedHandler: (NetworkID) -> Void = { _ in
    debugPrint("PeerDisappearedHandler not imp") }

  private(set) var messageHandler: (NetworkID, NetworkMessage) -> Void = { _,_ in
    debugPrint("MessageHandler not imp") }

  private(set) var timeTickHandler: (NetworkTime) -> Void = { _ in
    debugPrint("TimeTickHandler not imp") }

  private(set) var userDataUpdateHandler: () -> Void = {
    debugPrint("UserDataUpdateHandler not imp") }

  // callbacks

  func registerPeerAppearedHandler(fn: @escaping (NetworkID) -> Void) {
    peerAppearedHandler = fn
  }

  func registerPeerDisappearedHandler(fn: @escaping (NetworkID) -> Void) {
    peerDisappearedHandler = fn
  }

  func registerMessageHandler(fn: @escaping (NetworkID, NetworkMessage) -> Void) {
    messageHandler = fn
  }

  func registerTimeTickHandler(fn: @escaping (NetworkTime) -> Void) {
    timeTickHandler = fn
  }

  func registerUserDataUpdateHandler(fn: @escaping () -> Void) {
    userDataUpdateHandler = fn
  }

//  func SendDebugData(interface{})

}
