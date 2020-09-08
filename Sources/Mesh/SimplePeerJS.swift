import Foundation
import JavaScriptCore

class SimplePeerJS {

  private let context = JSContext()!
  private var api: APIFuncs!

  private static var checkisonce: SimplePeerJS?

  init(api: APIFuncs) {
    if SimplePeerJS.checkisonce == nil {
      SimplePeerJS.checkisonce = self
    } else {
      assertionFailure()
      fatalError()
    }

    self.api = api

    if let url = Bundle.main.url(forResource: "local_peer_model", withExtension: "js"),
      let data = try? Data(contentsOf: url).string {

      let result = context
        .evaluateScript(data)

      let closure: @convention(block) (NetworkID, NetworkMessage) -> Void = { peerID, data in
        self.api.sendToPeer(peerID: peerID, data: data)
      }

      context.setObject(closure, forKeyedSubscript: "sendToPeer" as NSString)

      context
        .objectForKeyedSubscript("letsgo")
        .call(withArguments: [api.myID() , api])

      debugPrint(result ?? "--no js value returned")

      context.exceptionHandler = { ctx, value in
        debugPrint(#function, ctx, value?.toString())

      }

//      let letsgoRes = context.objectForKeyedSubscript("letsgo").call(withArguments: [api.myID() , api])
//      debugPrint("letsgoRes ", letsgoRes)

//      let res2 =  result?
//        .objectForKeyedSubscript("simplePeerInstance")
//        .objectForKeyedSubscript("isendmessage")
//        .call(withArguments: ["text"])
//      debugPrint("res2 - ", res2)
    }
  }

  func isendmessage(text: NetworkMessage) {
    context
      .objectForKeyedSubscript("isendmessage")
      .call(withArguments: [text])
  }

  var messages: [BroadMessage] {
    if let meshNetworkState = context
        .objectForKeyedSubscript("meshNetworkState")?
        .call(withArguments: [])
        .toDictionary() {

      return meshNetworkState
        .map({ key, val in
          return BroadMessage(ti: val as? , msg: <#T##String#>, from: (key as? String) ?? "no key")
        })
        .map { (key: NetworkID, value: peerState) in
          BroadMessage(ti: value.UpdateTS,
                       msg: value.UserState.Message,
                       from: key)
      }
    }

//    assertionFailure("'no meshNetworkState")

    return [.init(ti: Date.timeIntervalSinceReferenceDate, msg: "0", from: "0")]
  }

}


extension SimplePeerJS: JSExport, APIFuncs {

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
    api.sendToPeer(peerID: peerID, data: data)

  }

}

extension SimplePeerJS: APICallbacks {

  func tick(ts: NetworkTime) {
    let fun = context
//      .objectForKeyedSubscript("simplePeerInstance")
      .objectForKeyedSubscript("tick")

    let res = fun?.call(withArguments: [ts])
    debugPrint(res?.toString())
  }

  func foundPeer(peerID: NetworkID) {
    context
//      .objectForKeyedSubscript("simplePeerInstance")
      .objectForKeyedSubscript("foundPeer")
      .call(withArguments: [peerID])
  }

  func lostPeer(peerID: NetworkID) {
    context
//      .objectForKeyedSubscript("simplePeerInstance")
      .objectForKeyedSubscript("lostPeer")?
      .call(withArguments: [peerID])
  }

  func didReceiveFromPeer(peerID: NetworkID, data: NetworkMessage) {
    context
//      .objectForKeyedSubscript("simplePeerInstance")
      .objectForKeyedSubscript("didReceiveFromPeer")
      .call(withArguments: [peerID, data])

  }

}

extension APIFuncs where Self: JSExport {




}
