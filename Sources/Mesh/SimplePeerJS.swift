import Foundation
import JavaScriptCore

class SimplePeerJS {

  private let context = JSContext()!
  private var api: APIFuncs!

  init(api: APIFuncs, didChangeState: @escaping AnyVoid) {

    self.api = api
    self.didChangeState = didChangeState

    if let url = Bundle.main.url(forResource: "local_peer_model", withExtension: "js"),
      let data = try? Data(contentsOf: url).string {

      let result = context.evaluateScript(data)
      debugPrint(result ?? "--no js value returned")

      context.exceptionHandler = { ctx, value in
        debugPrint(#function, ctx, value?.toString())

      }

      context.objectForKeyedSubscript("letsgo")?.call(withArguments: [api.myID() , api])

    }
  }

  func isendmessage(text: NetworkMessage) {
    context
      .objectForKeyedSubscript("simplePeerInstance.isendmessage")?
      .call(withArguments: [text])
  }

  var didChangeState: AnyVoid = { debugPrint("didChangeState non implemented") }

  var messages: [BroadMessage] {
    if let meshNetworkState = context.objectForKeyedSubscript("this.meshNetworkState")?.toDictionary() as? [NetworkID: peerState] {

      return meshNetworkState
        .map { (key: NetworkID, value: peerState) in
          BroadMessage(ti: value.UpdateTS,
                       msg: value.UserState.Message,
                       from: key)
      }
    }

//    assertionFailure("'no meshNetworkState")

    return []
  }

}


extension SimplePeerJS: JSExport, APIFuncs {

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
    api.sendToPeer(peerID: peerID, data: data)

    didChangeState()
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

    didChangeState()
  }

}
