import Foundation

struct BroadMessage: Equatable {

  let ti: Double
  let msg: String
  let from: String

}

protocol UiHandler: class {

  var reloadHandler: AnyVoid { get set }
  func sendMessage(_ text: String)

}

protocol UiProvider {

  var dataCount: Int { get }
  func dataAt(_ indexPath: IndexPath) -> BroadMessage

}

class MeshController: NSObject, UiHandler {

  weak var api: APIFuncs!

  private lazy var simplePeer = SimplePeerJS(api: api, didChangeState: reloadHandler)

  // MARK: - UiHandler

  var reloadHandler: AnyVoid = { debugPrint("reloadHandler not set up") }

  func sendMessage(_ text: String) {
    simplePeer.isendmessage(text: text)
//    simplePeer.SetState(p: PeerUserState(Coordinates: [0,0], Message: text))
  }

}

// MARK: - UiProvider

extension MeshController: UiProvider {

  private var mess: [BroadMessage] {
    simplePeer.messages
  }

  func dataAt(_ indexPath: IndexPath) -> BroadMessage {
    mess[indexPath.row]
  }

  var dataCount: Int {
    mess.count
  }

}

extension MeshController: APICallbacks {

  func tick(ts: TimeInterval) {
    simplePeer.tick(ts: ts)
  }

  func foundPeer(peerID: String) {
    simplePeer.foundPeer(peerID: peerID)
  }

  func lostPeer(peerID: String) {
    simplePeer.lostPeer(peerID: peerID)
  }

  func didReceiveFromPeer(peerID: String, data: NetworkMessage) {
//    reloadHandler()
//    if let str = data.string {
    simplePeer.didReceiveFromPeer(peerID: peerID, data: data)
//    }
  }

}
