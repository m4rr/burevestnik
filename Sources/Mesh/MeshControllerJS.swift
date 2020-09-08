import Foundation
import JavaScriptCore

public
class MeshControllerJS {

  private let context = JSContext()!

  init() {
    runJS()
  }

//  private lazy var api = MeshAPI()

  private func runJS() {

    guard let script = jsScript  else {
      return
    }

//    let block: @convention(block) (CVaListPointer) -> Void = { vaList in
//      debugPrint(vaList)
//    }
    let logger: @convention(block) (String, String) -> Void = { s1, s2 in
      debugPrint(s1,s2)
    }

    context.setObject(logger, forKeyedSubscript: "log" as NSString)

//    context.setObject(api, forKeyedSubscript: "api" as NSString)
    context.setObject(MeshAPI.self, forKeyedSubscript: "MeshAPI" as NSString)


//    let getMyID: @convention(block) () -> String = { () -> String in
//      return "kekekekek"
//    }
//    context.setObject(getMyID, forKeyedSubscript: "api.getMyID" as (NSCopying & NSObjectProtocol))


    context.exceptionHandler = { ctx, value in
      debugPrint(ctx ?? "js exception no ctx",
                 value?.toString() ?? "js exception no value")
    }

    let result = context.evaluateScript(script)
    debugPrint("evaluateScript result - ", result ?? "no result")
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

}
