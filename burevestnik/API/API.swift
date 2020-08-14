//
//  API.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

protocol API {

  func getTime()

  func foundPeer()
  func lostPeer()

  func sendToPeer()
  func didReceiveFromPeer()

  var delegate: APIDelegate? { get set }

}

protocol APIDelegate: class {

  func sendToPeer()

}

protocol NetInvoker {
  func invoke(cmd: Command, args: Arguments)
}

class RealAPI: API {

  var btMan: BtMan!

  weak var delegate: APIDelegate?

  func getTime() {
    //
  }

  func foundPeer() {
    // meshCon.foundPeer
  }

  func lostPeer() {
    // meshCon.lostPeer
  }

  func sendToPeer() {
    btMan.sendToPeer()
  }

  func didReceiveFromPeer() {
    // meshCon.didReceiveFromPeer
  }

}

class SimulationAPI: API {

  weak var delegate: APIDelegate?

  func getTime() {
    //
  }

  func foundPeer() {
    // meshCon.foundPeer
  }

  func lostPeer() {
    // meshCon.lostPeer
  }

  func sendToPeer() {
    //    BtMan().send
  }

  func didReceiveFromPeer() {
    // meshCon.didReceiveFromPeer
  }



}
