//
//  API.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

class API {

  var net: LocalNetwork!

  func invoke(cmd: Command, args: Arguments) {
    switch cmd {
    case .getTime:
      net.send(RPCResponse(time: Date().timeIntervalSince1970))

    case .foundPeer:
      net.send(RPCRequest(cmd: cmd, args: args))

    case .lostPeer:
      net.send(RPCRequest(cmd: cmd, args: args))

    case .sendToPeer:
      guard let peerID = args.peerID, let data = args.data else { return }

      net.sendToPeer()

      sessionSend(to: peerID, data: data)

    case .didReceiveFromPeer:
      net.send(RPCRequest(cmd: cmd, args: args))

    }
  }


}
