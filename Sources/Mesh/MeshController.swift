import Foundation

enum meshsim {
  typealias NetworkTime = TimeInterval
  typealias NetworkID = String
  typealias NetworkMessage = String
}


struct pkgStateUpdate: Codable {
  var TS: meshsim.NetworkTime, Data: String
}

struct pkgStateUpdateReceivedAck: Codable {
  let TS: meshsim.NetworkTime
}

struct pkg: Codable {
  let `Type`: String, Content: String
}

class peerToPeerSyncer {

  internal init(lastAttemptTS: meshsim.NetworkTime, lastTickTime: meshsim.NetworkTime, synced: Bool, delay: meshsim.NetworkTime, sender: @escaping (pkgStateUpdate) -> Void, updatePkg: pkgStateUpdate) {
    self.lastAttemptTS = lastAttemptTS
    self.lastTickTime = lastTickTime
    self.synced = synced
    self.delay = delay
    self.sender = sender
    self.updatePkg = updatePkg
  }

  var
    lastAttemptTS: meshsim.NetworkTime,
    lastTickTime:  meshsim.NetworkTime,
    synced:        Bool,
    delay:         meshsim.NetworkTime,
    sender:        (pkgStateUpdate) -> Void,

    updatePkg: pkgStateUpdate


  func updateData(_ data: String) {
    self.synced = false
    self.lastAttemptTS = 0
    self.updatePkg.Data = data
    self.updatePkg.TS = self.lastTickTime

    self.tick(self.lastTickTime)
  }


  func tick(_ ts: meshsim.NetworkTime) {
    if !self.synced && ts - self.lastAttemptTS >= self.delay {
      self.lastAttemptTS = ts
      self.sender(self.updatePkg)
    }
    self.lastTickTime = ts
  }

  func handleAck(ackPkg: pkgStateUpdateReceivedAck) {
    if self.synced {
      return
    }
    if ackPkg.TS == self.updatePkg.TS {
      self.synced = true
    }
  }

}

func newPeerToPeerSyncer(sender: @escaping (pkgStateUpdate) -> Void) -> peerToPeerSyncer {
  return peerToPeerSyncer(
    lastAttemptTS: 0,
    lastTickTime:  0,
    synced:        true,
    delay:         30000,
    sender:        sender,
    updatePkg:     pkgStateUpdate(TS: 0, Data: "")
  )
}

// PeerUserState contains user data
struct PeerUserState: Codable  {
  let
    Coordinates: [Double],
    Message:     String
}

struct peerState: Codable  {
  let
    UserState: PeerUserState,
    UpdateTS:  meshsim.NetworkTime
}

// SimplePeer1 provides simplest flood peer strategy
class SimplePeer1 {
  internal init(sender: @escaping (meshsim.NetworkID, meshsim.NetworkMessage) -> Void, ID: meshsim.NetworkID, Label: String, syncers: [meshsim.NetworkID : peerToPeerSyncer], meshNetworkState: [meshsim.NetworkID : peerState], currentTS: meshsim.NetworkTime = 0, testStateSet: Bool = false) {
    self.sender = sender
    self.ID = ID
    self.Label = Label
    self.syncers = syncers
    self.meshNetworkState = meshNetworkState
    self.currentTS = currentTS
    self.testStateSet = testStateSet
  }

  var
//      logger  *log.Logger
    sender:  (_ id: meshsim.NetworkID, _ data: meshsim.NetworkMessage) -> Void,
    ID:      meshsim.NetworkID,
    Label:   String,
    syncers: [meshsim.NetworkID: peerToPeerSyncer],

    meshNetworkState: [meshsim.NetworkID: peerState],
    currentTS:        meshsim.NetworkTime,

    testStateSet: Bool

  // HandleAppearedPeer implements crowd.MeshActor
  func HandleAppearedPeer(id: meshsim.NetworkID) {
    self.syncers[id] = newPeerToPeerSyncer(sender: { (d: pkgStateUpdate) in
      guard let bt = try? JSONEncoder().encode(d).string else {
        debugPrint("err.Error()", #function)
        return
      }

      let p = pkg(Type: "pkgStateUpdate", Content: bt)
      guard let bt2 = try? JSONEncoder().encode(p).string else {
        debugPrint("err.Error()", #function)
        return
      }
      self.sender(id, bt2)
    })

    if self.meshNetworkState.count > 0 {
      guard let serialisedState = try? JSONEncoder().encode(self.meshNetworkState).string else {
        debugPrint("err.Error()", #function)
        return
      }

      self.syncers[id]?.updateData(serialisedState)
    }
  }

  // HandleDisappearedPeer implements crowd.MeshActor
  func HandleDisappearedPeer(id: meshsim.NetworkID) {
    syncers.removeValue(forKey: id)
  }

  func handleNewIncomingState(sourceID: meshsim.NetworkID, update: pkgStateUpdate) {

    var somethingChanged = false
    if let _data = update.Data.data, let newNetworkState = try? JSONDecoder().decode([meshsim.NetworkID: peerState].self, from: _data) { // json.Unmarshal

      for (id, newPeerState) in newNetworkState {
        if let existingPeerState = self.meshNetworkState[id] {
          if existingPeerState.UpdateTS < newPeerState.UpdateTS {
            somethingChanged = true
            self.meshNetworkState[id] = newPeerState
          }
        } else {
          somethingChanged = true
          self.meshNetworkState[id] = newPeerState
        }
      }

    } else {
      debugPrint("th.logger.Println(err.Error())", #function)
      return
    }

    if somethingChanged {
      guard let serialisedState = try? JSONEncoder().encode(self.meshNetworkState).string else { // json.Marshal
        debugPrint("th.logger.Println(err.Error())", #function)
        return
      }

      for (id, syncer) in self.syncers {
        if sourceID == id {
          continue
        }
        syncer.updateData(serialisedState)
      }
    }
  }

  // HandleMessage implements crowd.MeshActor
  func HandleMessage(id: meshsim.NetworkID, data: meshsim.NetworkMessage) {
    guard let _data = data.data, let inpkg = try? JSONDecoder().decode(pkg.self, from: _data) else {
      debugPrint("th.logger.Println(err.Error())", #function)
      return
    }

    switch inpkg.Type {
    case "pkgStateUpdate":

      guard let _data = inpkg.Content.data, let update = try? JSONDecoder().decode(pkgStateUpdate.self, from: _data) else {
        debugPrint("case pkgStateUpdate - (err.Error())", #function)
        return
      }

      self.handleNewIncomingState(sourceID: id, update: update)

      let ack = pkgStateUpdateReceivedAck(TS: update.TS)

      guard let ser = try? JSONEncoder().encode(ack).string,
            let bt2 = try? JSONEncoder().encode(pkg(Type: "pkgStateUpdateReceivedAck", Content: ser)).string else {
        debugPrint("th.logger.Println(err.Error())")
        return
     }

      self.sender(id, bt2)

    case "pkgStateUpdateReceivedAck":
      if let p = self.syncers[id] {
        if let _data = inpkg.Content.data, let ack = try? JSONDecoder().decode(pkgStateUpdateReceivedAck.self, from: _data) {
          p.handleAck(ackPkg: ack)
        }
      }

    default:
      ()
    }
  }

  // RegisterMessageSender implements crowd.MeshActor
  func RegisterMessageSender(handler: @escaping (_ id: meshsim.NetworkID, _ data: meshsim.NetworkMessage) -> Void) {
    self.sender = handler
  }

  // HandleTimeTick implements crowd.MeshActor
  func HandleTimeTick(ts: meshsim.NetworkTime) {
    self.currentTS = ts
    for (_, s) in self.syncers {
      s.tick(ts)
    }

    if !self.testStateSet {
      self.testStateSet = true
      self.SetState(p: PeerUserState(Coordinates: [], Message: String.init(format: "Fuu from %@", self.Label)))
    }
  }

  // DebugData implements crowd.MeshActor
  func DebugData() -> [meshsim.NetworkID: peerState] {
    return meshNetworkState
  }

  // NewSimplePeer1 returns new SimplePeer1
  class func NewSimplePeer1(label: String) -> SimplePeer1 {
    return SimplePeer1(
      //      logger:           logger,
      sender:            { _, _ in debugPrint("Not registered") },
      ID:               "",
      Label:            label,
      syncers:          [meshsim.NetworkID: peerToPeerSyncer](),
      meshNetworkState: [meshsim.NetworkID: peerState]()
    )
  }

  // SetState updates this peer user data
  func SetState(p: PeerUserState) {
    self.meshNetworkState[self.ID] = peerState(
      UserState: p,
      UpdateTS:  self.currentTS
    )


    guard let serialisedState = try? JSONEncoder().encode(self.meshNetworkState).string else {
      debugPrint("th.logger.Println(err.Error())")
      return
    }

    for (_, syncer) in self.syncers {
      syncer.updateData(serialisedState)
    }
  }

}

class MeshController: NSObject {

  #warning("stub")
  private let simplePeer = SimplePeer1.NewSimplePeer1(label: "test-iphone-11-sim")

  var reloadHandler: AnyVoid = { fatalError("set up yours") }

  func broadcastMessage(_ text: String) {
//    peers.forEach { (peerID) in
//      if let data = text.data {
//        api?.sendToPeer(peerID: peerID, data: data)
//      }
//    }
    fatalError("dont use it, yet")
  }

  var messages: [BroadMessage] = [.init("Сообщения пока не работают")]
//  var peers = [String]()

  weak var api: APIFuncs?

//  func notifySomeone() {
//    api?.sendToPeer(peerID: "", data: Data())
//    #warning("stub")
//  }

}

extension MeshController: APICallbacks {
  
  func tick(ts: Date) {
    // do something if needed
    
    simplePeer.HandleTimeTick(ts: ts.timeIntervalSince1970)
  }

  func foundPeer(peerID: String, date: Date) {
    simplePeer.HandleAppearedPeer(id: peerID)
  }

  func lostPeer(peerID: String, date: Date) {
    simplePeer.HandleDisappearedPeer(id: peerID)
  }

  func didReceiveFromPeer(peerID: String, data: Data) {
//    reloadHandler()
    if let str = data.string {
      simplePeer.HandleMessage(id: peerID, data: str)
    }
  }

}
