import Foundation
import JavaScriptCore

public class MeshControllerJS {

  private let context = JSContext()! // old-fashioned objc api offers to use it explicitly, see docs
  private var meshAPI: MeshAPIExports
  private var frontendAPI: FrontendAPIExports

  init(frontendAPI: FrontendAPIExports) {

    self.meshAPI = MeshAPI()
    self.frontendAPI = frontendAPI

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
    context.setObject(unsafeBitCast(logger, to: AnyObject.self),
                      forKeyedSubscript: "log" as NSString)

//    context.setObject(HandleUpdate.self,
//                      forKeyedSubscript: "HandleUpdate" as NSString)

    context.setObject(unsafeBitCast(meshAPI, to: AnyObject.self),
                      forKeyedSubscript: "meshAPI" as NSString)

    context.setObject(unsafeBitCast(frontendAPI, to: AnyObject.self),
                      forKeyedSubscript: "frontendAPI" as NSString)

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

}
