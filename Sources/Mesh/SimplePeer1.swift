import Foundation

struct pkgStateUpdate: Codable {
  var TS: NetworkTime, Data: [NetworkID: peerState] = [:]
}

//struct pkgStateUpdateReceivedAck: Codable {
//  let TS: NetworkTime
//}

struct pkg: Codable {
  let `Type`: String, Content: pkgStateUpdate
}

class peerToPeerSyncer {

  internal init(lastAttemptTS: NetworkTime, lastTickTime: NetworkTime, synced: Bool, delay: NetworkTime, sender: @escaping (pkgStateUpdate) -> Void, updatePkg: pkgStateUpdate) {
    self.lastAttemptTS = lastAttemptTS
    self.lastTickTime = lastTickTime
    self.synced = synced
    self.delay = delay
    self.sender = sender
    self.updatePkg = updatePkg
  }

  var
    lastAttemptTS: NetworkTime,
    lastTickTime:  NetworkTime,
    synced:        Bool,
    delay:         NetworkTime,
    sender:        (pkgStateUpdate) -> Void,

    updatePkg: pkgStateUpdate


  func updateData(_ data: String) {
    self.synced = false
    self.lastAttemptTS = 0

    if let _data = data.data, let state = try? JSONSerialization.jsonObject(with: _data, options: []) as? [NetworkID: peerState] {
      self.updatePkg.Data = state
    }

    self.updatePkg.TS = self.lastTickTime

    self.tick(self.lastTickTime)
  }


  func tick(_ ts: NetworkTime) {
    if !self.synced && ts - self.lastAttemptTS >= self.delay {
      self.lastAttemptTS = ts
      self.sender(self.updatePkg)
    }
    self.lastTickTime = ts
  }

  func handleAck(ackPkg: pkgStateUpdate) {
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
    updatePkg:     pkgStateUpdate(TS: 0, Data: [:])
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
    UpdateTS:  NetworkTime
}

// SimplePeer1 provides simplest flood peer strategy
class SimplePeer1 {

  init(label: String, api: APIFuncs, didChangeState: @escaping AnyVoid) {

    self.api = api
    self.Label = label
    self.didChangeState = didChangeState

    syncers =          [NetworkID: peerToPeerSyncer]()
    meshNetworkState = [NetworkID: peerState]()

    currentTS = NetworkTime()
    testStateSet = false
  }

  var
    api: APIFuncs,
//      logger  *log.Logger
    Label:   String,
    syncers: [NetworkID: peerToPeerSyncer],
    currentTS:        NetworkTime,
    testStateSet: Bool

  var didChangeState: AnyVoid = { debugPrint("didChangeState non implemented") }
  var meshNetworkState: [NetworkID: peerState] {
    didSet {
      messages = meshNetworkState
        .map { (key: NetworkID, value: peerState) in
          BroadMessage(ti: Date(timeIntervalSince1970: value.UpdateTS),
                       msg: value.UserState.Message,
                       from: key)
        }
    }
  }

  public var messages: [BroadMessage] = [] {
    didSet {
//      assert(Thread.isMainThread)
      DispatchQueue.main.async(execute: didChangeState)
    }
  }

  // HandleAppearedPeer implements crowd.MeshActor
  func handleAppearedPeer(id: NetworkID) {
    self.syncers[id] = newPeerToPeerSyncer(sender: { (d: pkgStateUpdate) in
//      guard let bt = try? JSONEncoder().encode(d).string else {
//        debugPrint("err.Error()", #function)
//        return
//      }

      let p = pkg(Type: "pkgStateUpdate", Content: d)
      guard let bt2 = try? JSONEncoder().encode(p).string else {
        debugPrint("err.Error()", #function)
        return
      }
      self.api.sendToPeer(peerID: id, data: bt2)
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
  func handleDisappearedPeer(id: NetworkID) {
    syncers.removeValue(forKey: id)
  }

  func handleNewIncomingState(sourceID: NetworkID, update: pkgStateUpdate) {

    var somethingChanged = false
//    if let _data = update.Data.data, let newNetworkState = try? JSONDecoder().decode([NetworkID: peerState].self, from: _data) { // json.Unmarshal

      for (id, newPeerState) in update.Data {
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

//    } else {
//      debugPrint("th.logger.Println(err.Error())", #function)
//      return
//    }

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
  func handleMessage(id: NetworkID, data: NetworkMessage) {
    guard let _data = data.data, let inpkg = try? JSONDecoder().decode(pkg.self, from: _data) else {
      debugPrint("th.logger.Println(err.Error())", #function)
      return
    }

    switch inpkg.Type {
    case "pkgStateUpdate":

      let update = inpkg.Content

      self.handleNewIncomingState(sourceID: id, update: update)

      let ack = pkgStateUpdate(TS: update.TS, Data: [:])

      guard let bt2 = try? JSONEncoder().encode(pkg(Type: "pkgStateUpdateReceivedAck", Content: ack)).string else {
        debugPrint("th.logger.Println(err.Error())")
        return
     }

      self.api.sendToPeer(peerID: id, data: bt2)

    case "pkgStateUpdateReceivedAck":
      if let p = self.syncers[id] {

          p.handleAck(ackPkg: inpkg.Content)

      }

    default:
      ()
    }
  }

  // HandleTimeTick implements crowd.MeshActor
  func handleTimeTick(ts: NetworkTime) {
    self.currentTS = ts
    for (_, s) in self.syncers {
      s.tick(ts)
    }

    if !self.testStateSet {
      self.testStateSet = true
      self.SetState(p: PeerUserState(Coordinates: [0,0],
                                     Message: String(format: "Fuu from %@", self.Label)))
    }
  }

//  // DebugData implements crowd.MeshActor
//  func DebugData() -> [NetworkID: peerState] {
//    return meshNetworkState
//  }

//  // NewSimplePeer1 returns new SimplePeer1
//  class func NewSimplePeer1(label: String, api: APIFuncs) -> SimplePeer1 {
//    see SimplePeer1.init
//  }


  // SetState updates this peer user data
  func SetState(p: PeerUserState) {
    self.meshNetworkState[self.api.myID()] = peerState(
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

