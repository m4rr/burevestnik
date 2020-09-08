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
