import Foundation
import JavaScriptCore

typealias NetworkMessage = String
typealias NetworkID = String
typealias NetworkTime = TimeInterval

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

protocol APIFuncs: class {

  /// 0
  func GetMyID() -> NetworkID

  /// 4
  func SendMessage(peerID: NetworkID, data: NetworkMessage)

}

protocol APICallbacks: class {

  /// 1
  func RegisterTimeTickHandler(fn: @escaping (NetworkTime) -> Void)

  /// 2
  func RegisterPeerAppearedHandler(fn: @escaping (NetworkID) -> Void)
  /// 3
  func RegisterPeerDisappearedHandler(fn: @escaping (NetworkID) -> Void)

  /// 5
  func RegisterMessageHandler(fn: @escaping (NetworkID, NetworkMessage) -> Void)

  func registerUserDataUpdateHandler(fn: @escaping () -> Void)

}

protocol MeshAPIProtocol: APIFuncs & APICallbacks, JSExport {

}

class MeshAPI: NSObject, MeshAPIProtocol {

  var localNetwork: APIFuncs!

  override init() {
    super.init()

    self.localNetwork = BtMan(meshAPI: self) // WebSocketConn()
  }

  // funcs

  func SendMessage(peerID: NetworkID, data: NetworkMessage) {
    localNetwork.SendMessage(peerID: peerID, data: data)
  }

  // callbacks

  private(set) var PeerAppearedHandler: (NetworkID) -> Void = { _ in
    debugPrint("PeerAppearedHandler not imp") }

  private(set) var PeerDisappearedHandler: (NetworkID) -> Void = { _ in
    debugPrint("PeerDisappearedHandler not imp") }

  private(set) var MessageHandler: (NetworkID, NetworkMessage) -> Void = { _,_ in
    debugPrint("MessageHandler not imp") }

  private(set) var TimeTickHandler: (NetworkTime) -> Void = { _ in
    debugPrint("TimeTickHandler not imp") }

  private(set) var UserDataUpdateHandler: () -> Void = {
    debugPrint("UserDataUpdateHandler not imp") }

  func RegisterPeerAppearedHandler(fn: @escaping (NetworkID) -> Void) {
    PeerAppearedHandler = fn
  }

  func RegisterPeerDisappearedHandler(fn: @escaping (NetworkID) -> Void) {
    PeerDisappearedHandler = fn
  }

  func RegisterMessageHandler(fn: @escaping (NetworkID, NetworkMessage) -> Void) {
    MessageHandler = fn
  }

  func SendMessage(id: NetworkID, data: NetworkMessage) {
    localNetwork.SendMessage(peerID: id, data: data)
  }

  func RegisterTimeTickHandler(fn: @escaping (NetworkTime) -> Void) {
    TimeTickHandler = fn
  }

  func registerUserDataUpdateHandler(fn: @escaping () -> Void) {
    UserDataUpdateHandler = fn
  }

//  func SendDebugData(interface{})

  func GetMyID() -> NetworkID {
    localNetwork.GetMyID()
  }

}
