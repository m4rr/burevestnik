import Foundation
import JavaScriptCore

class MeshControllerJS {

  private let context = JSContext()!

  init() {
    runJS()
  }

  private func runJS() {

    guard let script = jsScript  else {
      return
    }

    context
      .setObject(MeshAPI.self,
                 forKeyedSubscript: "MeshAPI"
                  as (NSCopying & NSObjectProtocol)) // as NSString)

    context.exceptionHandler = { ctx, value in
      debugPrint(ctx ?? "js exception no ctx",
                 value?.toString() ?? "js exception no value")
    }

    let result = context.evaluateScript(script)
    debugPrint("evaluateScript result - ", result ?? "no result")
  }

  private var jsURL: URL? {
    Bundle.main.url(forResource: "local_peer_model", withExtension: "js")
  }

  private var jsScript: String? {
    if let url = jsURL, let data = try? Data(contentsOf: url).string {
      return data
    }

    return nil
  }

}
