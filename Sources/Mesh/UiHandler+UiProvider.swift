import Foundation

struct BroadMessage: Equatable {

  let ti: NetworkTime
  let msg: NetworkMessage
  let from: NetworkID

  var simpleFrom: String {
    deviceNameRemovingUUID(from)
  }

  static func from(_ json: (key: AnyHashable, val: Any)) -> Self {

    let valueDic = json.val as? [String: Any]

    return BroadMessage(
      ti: (valueDic?["UpdateTS"] as? NetworkTime) ?? -1,
      msg: (valueDic?["UserState"] as? [String: String])?["Message"] ?? "-no-",
      from: json.key as? String ?? "-no key-")
  }

  private func deviceNameRemovingUUID(_ name: String) -> String {
    String(name.dropLast(uuidTakeLength))
  }
}

protocol UiHandler: class {

  var reloadHandler: AnyVoid { get set }
  func broadcastMessage(_ text: String)

}

protocol UiProvider {

  var dataCount: Int { get }
  func dataAt(_ indexPath: IndexPath) -> BroadMessage

  var numberOfPeers: Int { get }

//  func isConflicting(_ name: String) -> Bool

}
