import Foundation
import JavaScriptCore

class SimplePeerJS {

  private let context = JSContext()!
  private var api: APIFuncs!

  init(api: APIFuncs) {
    self.api = api

    if let url = Bundle.main.url(forResource: "local_peer_model", withExtension: "js"),
       let data = try? Data(contentsOf: url).string {

      let result = context.evaluateScript(data)

      debugPrint(result ?? "--no js value returned")

      context.exceptionHandler = { ctx, value in

        debugPrint(#function, ctx, value?.toString())

      }
    }
  }

}

extension SimplePeerJS: JSExport, APIFuncs {

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
    api.sendToPeer(peerID: peerID, data: data)
  }

}

extension SimplePeerJS: APICallbacks {

  func tick(ts: NetworkTime) {
    context
      .objectForKeyedSubscript("simplePeerInstance.tick")?
      .call(withArguments: [ts])
  }

  func foundPeer(peerID: NetworkID) {
    context
      .objectForKeyedSubscript("simplePeerInstance.foundPeer")?
      .call(withArguments: [peerID])
  }

  func lostPeer(peerID: NetworkID) {
    context
      .objectForKeyedSubscript("simplePeerInstance.lostPeer")?
      .call(withArguments: [peerID])
  }

  func didReceiveFromPeer(peerID: NetworkID, data: NetworkMessage) {
    context
      .objectForKeyedSubscript("simplePeerInstance.didReceiveFromPeer")?
      .call(withArguments: [peerID, data])
  }

}
