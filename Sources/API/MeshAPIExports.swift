import Foundation
import JavaScriptCore

typealias NetworkMessage = String
typealias NetworkID = String
typealias NetworkTime = Int

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

@objc protocol MeshAPIExports: JSExport {

  static func getInstance() -> MeshAPI

  // MARK: - Funcs

  /// 0
  func getMyID() -> NetworkID

  /// 4
  func sendMessage(_ peerID: NetworkID, _ data: NetworkMessage)

  func setDebugMessage(_ json: String)

  // MARK: - Callbacks (each recieves a function that cannot be expressed with Swift)
  
  /// 1
  func registerTimeTickHandler(_: JSValue)

  /// 2
  func registerPeerAppearedHandler(_: JSValue)
  /// 3
  func registerPeerDisappearedHandler(_: JSValue)

  /// 5
  func registerMessageHandler(_: JSValue)

  func registerUserDataUpdateHandler(_: JSValue)

}
