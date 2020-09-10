import Foundation
import JavaScriptCore

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

@objc protocol MeshAPIExports: JSExport {

  // MARK: - Funcs

  /// 0
  func getMyID() -> NetworkID

  /// 4
  func sendMessage(_ peerID: NetworkID, _ data: NetworkMessage)

  // MARK: - Callbacks (each recieves a function that cannot be expressed with Swift)
  
  /// 1
  func registerTimeTickHandler(_ f: JSValue)

  /// 2
  func registerPeerAppearedHandler(_ f: JSValue)

  /// 3
  func registerPeerDisappearedHandler(_ f: JSValue)

  /// 5
  func registerMessageHandler(_ f: JSValue)

  func registerUserDataUpdateHandler(_ f: JSValue)

}

/// Runs what's registered by `MeshAPIExports`

protocol MeshAPIProtocol {

//  var _peerAppearedHandler: JSValue! { get set }
  func peerAppearedHandler(_ id: NetworkID) -> Void

//  var _peerDisappearedHandler: JSValue! { get set }
  func peerDisappearedHandler(_ id: NetworkID) -> Void

//  var _messageHandler: JSValue! { get set }
  func messageHandler(_ id: NetworkID, _ data: NetworkMessage)

//  var _timeTickHandler: JSValue! { get set }
  func timeTickHandler(_ ts: NetworkTime)

//  var _userDataUpdateHandler: JSValue! { get set }
  func userDataUpdateHandler(data: NetworkMessage)

}
