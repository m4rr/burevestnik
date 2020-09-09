import Foundation
import JavaScriptCore

public class MeshControllerJS: UiHandler {

  private let context = JSContext()!
  private lazy var meshAPI = MeshAPI(handleUpdate: updateStuff)

  init() {
    runJS()
  }

  deinit {
    debugPrint("MeshControllerJS deinit")
  }

  private func runJS() {

    guard let script = jsScript  else {
      return
    }

    let logger: @convention(block) (String, String) -> Void = { s1, s2 in
      debugPrint(s1, s2 == "undefined" ? "" : s2)
    }
    context.setObject(
      unsafeBitCast(logger, to: AnyObject.self),
      forKeyedSubscript: "log" as NSString)

    context.setObject(
      unsafeBitCast(meshAPI, to: AnyObject.self),
      forKeyedSubscript: "api" as NSString)

//    context.setObject(MeshAPI.self, forKeyedSubscript: "MeshAPI" as NSString)

    context.exceptionHandler = { ctx, value in
      debugPrint(ctx ?? "js exception no ctx",
                 value?.toString() ?? "js exception no value")
    }

    if let result = context.evaluateScript(script) {
      debugPrint("evaluateScript result - ", result)
    } else {
      assertionFailure()
    }
  }

  private var jsURL: URL? {
    Bundle.main.url(forResource: "peer", withExtension: "js")
  }

  private var jsScript: String? {
    if let url = jsURL, let data = try? Data(contentsOf: url).string {
      return data
    }

    return nil
  }

  private func updateStuff() {
    data = getMessages()
  }

  var data: [BroadMessage] = [] {
    didSet {
      DispatchQueue.main.async {
        self.reloadHandler()
      }
    }
  }

  // MARK: - UiHandler

  var reloadHandler: AnyVoid = { debugPrint("reloadHandler not set up") }

  func broadcastMessage(_ text: String) {

    meshAPI.userDataUpdateHandler(data: text)




  }

}

// MARK: - UiProvider

extension MeshControllerJS: UiProvider {

  func getMessages() -> [BroadMessage] {

    if let msgs = context
        .objectForKeyedSubscript("meshNetworkState" as NSString)?
        .toDictionary() {

      let res =  msgs.map(BroadMessage.from)

      return res

    }

    return []
  }

  func dataAt(_ indexPath: IndexPath) -> BroadMessage {
    data[indexPath.row]
  }

  var dataCount: Int {
    data.count
  }

}
