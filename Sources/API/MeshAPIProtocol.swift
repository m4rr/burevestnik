import Foundation
import JavaScriptCore

typealias NetworkMessage = String
typealias NetworkID = String
typealias NetworkTime = TimeInterval

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

protocol LocalNetwork: class {

  /// 0
  func getMyID() -> NetworkID

  /// 4
  func sendMessage(peerID: NetworkID, data: NetworkMessage)

}

protocol MeshAPIProtocol: LocalNetwork, JSExport {

  /// 1
  func registerTimeTickHandler(fn: @escaping (NetworkTime) -> Void)

  /// 2
  func registerPeerAppearedHandler(fn: @escaping (NetworkID) -> Void)
  /// 3
  func registerPeerDisappearedHandler(fn: @escaping (NetworkID) -> Void)

  /// 5
  func registerMessageHandler(fn: @escaping (NetworkID, NetworkMessage) -> Void)

  func registerUserDataUpdateHandler(fn: @escaping () -> Void)

}
