//
//  WS.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

protocol LocalNetwork {

  var delegate: LocalNetworkDelegate? { get }

  func sendToPeer()

}

protocol LocalNetworkDelegate {

  func foundPeer()
  func lostPeer()

  func didReceiveFromPeer()

}

class WebSocketConn: LocalNetwork {

  var delegate: LocalNetworkDelegate?

  func sendToPeer() {
    #warning("stub")
  }

  private let wsURL: URL
  private var wsTask: URLSessionWebSocketTask?

  private let mesh: MeshNetInvoker

  init(url: URL, delegate: LocalNetworkDelegate) {
    self.wsURL = url
    self.delegate = delegate
  }

  func connect() {
    wsTask?.cancel(with: .normalClosure, reason: nil)

    wsTask = URLSession.shared.webSocketTask(with: wsURL)
    wsTask?.resume()

    receieve()
  }

  func receieve() {

    wsTask?.receive { [weak self] (result) in
      switch result {
      case .failure(let err):
        debugPrint(err)
      //        self?.failure()

      case .success(let message):
        //        self?.success()

        switch message {
        case .string(let text):
          debugPrint("Received string: \(text)")

        case .data(let data):
          guard let request = try? JSONDecoder().decode(RPCRequest.self, from: data) else { return }

          self?.mesh.invoke(cmd: request.cmd, args: request.args)

        default:
          fatalError()
        }

        self?.receieve()

      }
    }
  }


  func send(_ data: Codable) {
    func s(_ d: Data) {
      wsTask?.send(.data(d)) { (err) in
        if let err = err {
          debugPrint(err)
        }
      }
    }

    if let rq = (data as? RPCRequest), let json = try? JSONEncoder().encode(rq) {
      debugPrint(json)
      s(json)

    } else if let rp = (data as? RPCRequest), let json = try? JSONEncoder().encode(rp) {
      debugPrint(json)
      s(json)
    }
  }

}
