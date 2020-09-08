import Foundation
import JavaScriptCore

public class MeshControllerJS: UiHandler {

  private let context = JSContext()!

  init() {
    runJS()
  }

  deinit {
    //
  }

  private lazy var meshAPI = MeshAPI()

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


  // MARK: - UiHandler

  var reloadHandler: AnyVoid = { debugPrint("reloadHandler not set up") }

  func sendMessage(_ text: String) {

//    let res =
//    context
//      .objectForKeyedSubscript("handleUserData")?
//      .call(withArguments: )


//    debugPrint("handleUserData", res)

    meshAPI.userDataUpdateHandler(data: text)



    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
      self.reloadHandler()
    }
  }

}

// MARK: - UiProvider

extension MeshControllerJS: UiProvider {

  private var mess: [BroadMessage] {
    let msgs = context
      .objectForKeyedSubscript("meshNetworkState" as NSString)?
      .call(withArguments: [])


    debugPrint("msgs", msgs, msgs?.toDictionary())

    return []
  }

  func dataAt(_ indexPath: IndexPath) -> BroadMessage {
    mess[indexPath.row]
  }

  var dataCount: Int {
    mess.count
  }

}

