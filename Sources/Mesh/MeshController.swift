import Foundation

struct BroadMessage: Equatable {

  let ti: Date
  let msg: String
  let from: String

}

protocol UiHandler {

  var reloadHandler: AnyVoid { get set }
  func sendMessage(_ text: String)

}

protocol UiProvider {

  var dataCount: Int { get }
  func dataAt(_ indexPath: IndexPath) -> BroadMessage

}

class MeshController: NSObject, UiHandler {

  weak var api: APIFuncs!

  private lazy var simplePeer = SimplePeer1(label: "iphone-test", api: api, didChangeState: reloadHandler)

  // MARK: - UiHandler

  var reloadHandler: AnyVoid = { debugPrint("reloadHandler not set up") }

  func sendMessage(_ text: String) {
    simplePeer.SetState(p: PeerUserState(Coordinates: [0,0], Message: text))
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

  func tick(ts: Date) {
    simplePeer.handleTimeTick(ts: ts.timeIntervalSince1970)
  }

  func foundPeer(peerID: String) {
    simplePeer.handleAppearedPeer(id: peerID)
  }

  func lostPeer(peerID: String) {
    simplePeer.handleDisappearedPeer(id: peerID)
  }

  func didReceiveFromPeer(peerID: String, data: Data) {
//    reloadHandler()
    if let str = data.string {
      simplePeer.handleMessage(id: peerID, data: str)
    }
  }

}
