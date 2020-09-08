import Foundation

struct BroadMessage: Equatable {

  let ti: Double
  let msg: String
  let from: String


  static func from(_ json: (key: AnyHashable, val: Any)) -> Self {

    return BroadMessage(
      ti: ((json.val as? [String: Any])?["UpdateTS"] as? Double) ?? 0,
      msg: ((json.val as? [String: Any])?["UserState"] as? [String: String])?["Message"] ?? "-no-",
      from: (json.key as? String) ?? "-no key-")
  }

}

protocol UiHandler: class {

  var reloadHandler: AnyVoid { get set }
  func sendMessage(_ text: String)

}

protocol UiProvider {

  var dataCount: Int { get }
  func dataAt(_ indexPath: IndexPath) -> BroadMessage

}

//class MeshController: NSObject, UiHandler {
//
//  weak var meshAPI: MeshAPI! {
//    didSet {
//      _ = simplePeer
//    }
//  }
//
//  private lazy var simplePeer = MeshControllerJS()
//
//  // MARK: - UiHandler
//
//  var reloadHandler: AnyVoid = { debugPrint("reloadHandler not set up") }
//
//  func sendMessage(_ text: String) {
////    simplePeer.isendmessage(text: text)
////    simplePeer.SetState(p: PeerUserState(Coordinates: [0,0], Message: text))
//
//    reloadHandler()
//  }
//
//}
//
//// MARK: - UiProvider
//
//extension MeshController: UiProvider {
//
//  private var mess: [BroadMessage] {
//    []
//  }
//
//  func dataAt(_ indexPath: IndexPath) -> BroadMessage {
//    mess[indexPath.row]
//  }
//
//  var dataCount: Int {
//    mess.count
//  }
//
//}
//
////extension MeshController: APICallbacks {
////
////  func tick(ts: TimeInterval) {
////    simplePeer.tick(ts: ts)
////
////  }
////
////  func foundPeer(peerID: String) {
////    simplePeer.foundPeer(peerID: peerID)
////    api.
////  }
////
////  func lostPeer(peerID: String) {
////    simplePeer.lostPeer(peerID: peerID)
////  }
////
////  func didReceiveFromPeer(peerID: String, data: NetworkMessage) {
//////    reloadHandler()
//////    if let str = data.string {
////    simplePeer.didReceiveFromPeer(peerID: peerID, data: data)
////
////    reloadHandler()
//////    }
////  }
////
////}
