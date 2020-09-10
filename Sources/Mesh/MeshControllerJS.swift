import Foundation
import JavaScriptCore

public class MeshControllerJS: UiHandler {

  private let context = JSContext()! // old-fashioned objc api offers to use it explicitly, see docs
  private lazy var meshAPI = MeshAPI(handleUpdate: updateStuff)

  init() {
    runJS()
  }

  deinit {
    debugPrint("MeshControllerJS deinit")
    assertionFailure()
  }

  private func runJS() {

    guard let url = peerJSURL, let script = contentsOf(url: url) else {
      return
    }

    let logger: @convention(block) (String, String) -> Void = { s1, s2 in
      // Swift cannot export `String...` or va_list to the JS
      debugPrint(s1, s2)
    }
    context.setObject(
      unsafeBitCast(logger, to: AnyObject.self),
      forKeyedSubscript: "log" as NSString)

    context.setObject(
      unsafeBitCast(meshAPI, to: AnyObject.self),
      forKeyedSubscript: "api" as NSString)

    // context.setObject(MeshAPI.self, forKeyedSubscript: "MeshAPI" as NSString)

    context.exceptionHandler = { ctx, value in
      assert(ctx != nil && ctx == self.context)

      debugPrint(value?.toString() ?? "js exception no value")
    }

    if let result = context.evaluateScript(script, withSourceURL: url) {
      debugPrint("evaluateScript result - ", result)
    } else {
      assertionFailure()
    }
  }

  private var peerJSURL: URL? {
    Bundle.main.url(forResource: "peer", withExtension: "js")
  }

  private func contentsOf(url: URL) -> String? {
    if let data = try? Data(contentsOf: url).string {
      return data
    }

    return nil
  }

  private func updateStuff() {

    let msgs = getMessages()
      .sorted { m1, m2 in
        m1.ti < m2.ti
      }

//    let cs = NSCountedSet(array: msgs.map { $0.simpleFrom })
//    conflictingShortNames = cs
//      .filter({ cs.count(for: $0) > 1 }) as? [String] ?? []

    data = msgs
  }

//  private var conflictingShortNames: [String] = []

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

  var numberOfPeers: Int {
    meshAPI.localNetwork.numberOfPeers
  }

  func getMessages() -> [BroadMessage] {

    // FIXME: use `handleUpdate` callback from JS

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

//  func isConflicting(_ name: String) -> Bool {
//    conflictingShortNames.contains(name)
//  }

}
