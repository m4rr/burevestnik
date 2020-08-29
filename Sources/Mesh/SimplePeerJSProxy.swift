import Foundation
import JavaScriptCore

class SimplePeerJS {

  let ctx = JSContext()!

  init() {
    if let url = Bundle.main.url(forResource: "local_peer_model", withExtension: "js"),
       let data = try? Data(contentsOf: url).string {

      let result = ctx.evaluateScript(data)

      debugPrint(result ?? "--no js value returned")
    }
  }

}
