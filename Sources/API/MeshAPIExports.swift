import Foundation
import JavaScriptCore

typealias NetworkMessage = String
typealias NetworkID = String
typealias NetworkTime = TimeInterval

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

protocol LocalNetwork: class {

  /// 0
  func getMyID() -> String

  /// 4
  func sendMessage(peerID: NetworkID, data: NetworkMessage)

}

@objc protocol MeshAPIExports: JSExport {

  static func getInstance() -> MeshAPI

  /// 0
  func getMyID() -> NetworkID

  /// 4
  func sendMessage(_ peerID: NetworkID, _ data: NetworkMessage)
  
  /// 1
  func registerTimeTickHandler(_: JSValue)

  /// 2
  func registerPeerAppearedHandler(_: JSValue)
  /// 3
  func registerPeerDisappearedHandler(_: JSValue)

  /// 5
  func registerMessageHandler(_: JSValue)

  func registerUserDataUpdateHandler(_: JSValue)

  func setDebugMessage(_ json: String)

}
