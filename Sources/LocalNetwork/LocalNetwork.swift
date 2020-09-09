import Foundation

protocol LocalNetwork: class {

  func myID() -> NetworkID

  func sendToPeer(id: NetworkID, data: NetworkMessage)

  var numberOfPeers: Int { get }

}
