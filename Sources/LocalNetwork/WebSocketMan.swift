import Foundation

protocol NetInvoker {
  func invoke(cmd: Command, args: Arguments)
}

enum Command: String, Codable {
  case tick,
       foundPeer,
       lostPeer,
       sendToPeer,
       didReceiveFromPeer
}

struct Arguments: Codable {
  let PeerID: String?, Data: String?, TS: TimeInterval?
}

class WebSocketConn {

  struct Request: Codable {
    let Cmd: Command, Args: Arguments
  }

  struct Response: Codable {
    enum Result: String, Codable {
      case ok
    }

    var result: Result = .ok
    let time: TimeInterval?
  }

  weak var api: APICallbacks! {
    didSet {
      connect()
    }
  }

  private let wssURL: URL
  private var wsTask: URLSessionWebSocketTask?

  init(wss: URL) {
    self.wssURL = wss
  }

  func connect() {
    wsTask?.cancel(with: .normalClosure, reason: nil)

    wsTask = URLSession.shared.webSocketTask(with: wssURL)
    wsTask?.resume()

    receieve()
  }

  func receieve() {

    wsTask?.receive { [weak self] (result) in
      switch result {
      case .failure(let err):
        debugPrint(err)

      case .success(let message):

        switch message {
        case .string(let text):
          debugPrint("Received string: \(text)")

          guard let data = text.data, let request = try? JSONDecoder().decode(Request.self, from: data) else { return }

          self?.invoke(cmd: request.Cmd, args: request.Args)

        default:
          assertionFailure()
        }

        self?.receieve()
      }
    }
  }

  func sendToWs(_ data: Codable) {

    func _send(_ str: String) {
      wsTask?.send(.string(str)) { (err) in
        if let err = err {
          debugPrint(err)
        }
      }
    }

    if let rq = (data as? Request), let json = try? JSONEncoder().encode(rq).string {
      _send(json)

    } else if let rp = (data as? Response), let json = try? JSONEncoder().encode(rp).string {
      _send(json)
    }
  }

}


extension WebSocketConn {

  func invoke(cmd: Command, args: Arguments) {

    switch cmd {

    // funcs

    case .tick:
      guard let TS = args.TS else { return }

      self.tick(ts: TS)

    case .sendToPeer:
      guard let peerID = args.PeerID, let data = args.Data else { return }

      self.sendToPeer(peerID: peerID, data: data)

    //      sessionSend(to: peerID, data: data)

    // callbacks

    case .foundPeer:
      guard let peerID = args.PeerID else { return }

      api.foundPeer(peerID: peerID)

    case .lostPeer:
      guard let peerID = args.PeerID else { return }

      api.foundPeer(peerID: peerID)

    case .didReceiveFromPeer:
      guard let peerID = args.PeerID, let data = args.Data?.data else { return }

      api.didReceiveFromPeer(peerID: peerID, data: data)

    }
  }

}

extension WebSocketConn: APIFuncs {

  func tick(ts: TimeInterval) {
    api.tick(ts: ts)
  }

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
    sendToWs(Request(Cmd: .sendToPeer,
                     Args: .init(PeerID: peerID,
                                 Data: data,
                                 TS: nil)))
  }

}
