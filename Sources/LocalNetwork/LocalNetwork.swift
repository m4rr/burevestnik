import Foundation

protocol LocalNetwork: class {

  func myID() -> String

  func sendToPeer(id: NetworkID, data: NetworkMessage)

  var numberOfPeers: Int { get }

}
