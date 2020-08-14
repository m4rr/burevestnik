//
//  Mesh.swift
//  burevestnik
//
//  Created by Marat Saytakov on 14.08.2020.
//

import Foundation

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
