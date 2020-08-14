//
//  Mesh.swift
//  burevestnik
//
//  Created by Marat Saytakov on 14.08.2020.
//

import Foundation

protocol MeshNetInvoker {
  func invoke(cmd: Command, args: Arguments)
}

enum Command: String, Codable {
  case
    getTime,
    foundPeer,
    lostPeer,
    sendToPeer,
    didReceiveFromPeer
}

struct Arguments: Codable {
  let peerID: String?, data: String?, time: TimeInterval?
}

struct RPCRequest: Codable {
  let cmd: Command, args: Arguments
}

struct RPCResponse: Codable {
  enum Result: String, Codable {
    case ok
  }

  var result: Result = .ok
  let time: TimeInterval?
}

//class APIMan: MeshNetInvoker {
//
//  func invoke(cmd: Command, args: Arguments) {
//    switch cmd {
//    case .getTime:
//      return .init(time: Date().timeIntervalSince1970)
//
//    case .foundPeer:
//      ()
//    case .lostPeer:
//      ()
//    case .sendToPeer:
//      // BtMan.sessionSend(to: peerID, data: data)
//      ()
//    case .didReceiveFromPeer:
//      ()
//    }
//
//    return .init(time: nil)
//  }
//
//}


