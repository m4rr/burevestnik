class pkgStateUpdate {
}
class pkgStateUpdateReceivedAck {
}
class pkg {
    constructor(Type, Content) {
        this.Type = Type;
        this.Content = Content;
    }
}
class debugDataStruct {
    constructor(MyID, MyTS, PeersState) {
        this.MyID = MyID;
        this.MyTS = MyTS;
        this.PeersState = PeersState;
    }
}
class peerToPeerSyncer {
    constructor(sender) {
        this.lastAttemptTS = 0;
        this.lastTickTime = 0;
        this.synced = true;
        this.delay = 30000;
        this.sender = sender;
        this.updatePkg = new pkgStateUpdate();
    }
    updateData(data) {
        this.synced = false;
        this.lastAttemptTS = 0;
        this.updatePkg.Data = data;
        this.updatePkg.TS = this.lastTickTime;
        this.tick(this.lastTickTime);
    }
    tick(ts) {
        if (!this.synced && ts - this.lastAttemptTS >= this.delay) {
            this.lastAttemptTS = ts;
            this.sender(this.updatePkg);
        }
        this.lastTickTime = ts;
    }
    handleAck(ackPkg) {
        if (this.synced) {
            return;
        }
        if (ackPkg.TS == this.updatePkg.TS) {
            this.synced = true;
        }
    }
}
// PeerUserState contains user data
class PeerUserState {
    constructor(Message) {
        this.Message = Message;
    }
}
class peerState {
    constructor(UserState, UpdateTS) {
        this.UserState = UserState;
        this.UpdateTS = UpdateTS;
    }
}
// SimplePeer1 provides simplest flood peer strategy
class SimplePeer1 {
    constructor(label, api) {
        this.api = api;
        this.Label = label;
        this.syncers = {};
        this.meshNetworkState = {};
        // api.RegisterMessageHandler((id: NetworkID, data: NetworkMessage) => {
        //     this.handleMessage(id, data)
        // })
        // api.RegisterPeerAppearedHandler((id: NetworkID) => {
        //     this.handleAppearedPeer(id)
        // })
        // api.RegisterPeerDisappearedHandler((id: NetworkID) => {
        //     this.handleDisappearedPeer(id)
        // })
        // api.RegisterTimeTickHandler((ts: NetworkTime) => {
        //     this.(ts)
        // })
    }
    // HandleAppearedPeer implements crowd.MeshActor
    foundPeer(peerID) { this.handleAppearedPeer(peerID); }
    handleAppearedPeer(id) {
        this.syncers[id] = new peerToPeerSyncer((d) => {
            let bt = JSON.stringify(d);
            if (bt == null) {
                console.log("err.Error()");
                return;
            }
            let p = new pkg("pkgStateUpdate", bt);
            let bt2 = JSON.stringify(p);
            if (bt2 == null) {
                console.log("err.Error()");
                return;
            }
            this.api.sendToPeer(id, bt2);
        });
        if (Object.keys(this.meshNetworkState).length > 0) {
            let serialisedState = JSON.stringify(this.meshNetworkState);
            if (serialisedState == null) {
                console.log("err.Error()");
                return;
            }
            this.syncers[id].updateData(serialisedState);
        }
    }
    lostPeer(peerID) { this.handleDisappearedPeer(peerID); }
    handleDisappearedPeer(id) {
        delete this.syncers[id];
    }
    sendDbgData() {
        //     this.api.SendDebugData(new debugDataStruct(
        //         this.api.GetMyID(),
        //         this.currentTS,
        //         this.meshNetworkState
        //     ))
    }
    handleNewIncomingState(sourceID, update) {
        let newNetworkState = JSON.parse(update.Data);
        let somethingChanged = false;
        if (newNetworkState != null) {
            for (let key in newNetworkState) {
                let newPeerState = newNetworkState[key];
                let existingPeerState = this.meshNetworkState[key];
                if (existingPeerState == null) {
                    somethingChanged = true;
                    this.meshNetworkState[key] = newPeerState;
                }
                else {
                    if (existingPeerState.UpdateTS < newPeerState.UpdateTS) {
                        somethingChanged = true;
                        this.meshNetworkState[key] = newPeerState;
                    }
                }
            }
        }
        else {
            console.log("err.Error()");
            return;
        }
        if (somethingChanged) {
            this.sendDbgData();
            let serialisedState = JSON.stringify(this.meshNetworkState);
            if (serialisedState == null) {
                console.log("err.Error()");
                return;
            }
            for (let key in this.syncers) {
                let syncer = this.syncers[key];
                if (sourceID == key) {
                    continue;
                }
                syncer.updateData(serialisedState);
            }
        }
    }
    didReceiveFromPeer(peerID, data) { this.handleMessage(peerID, data); }
    handleMessage(id, data) {
        // let inpkg = new pkg()
        let inpkg = JSON.parse(data); // Unmarshal
        if (inpkg == null) {
            console.log("err.Error()");
            return;
        }
        switch (inpkg.Type) {
            case "pkgStateUpdate":
                let update = JSON.parse(inpkg.Content); // Unmarshal
                this.handleNewIncomingState(id, update);
                let ack = new pkgStateUpdateReceivedAck();
                ack.TS = update.TS;
                let ser = JSON.stringify(ack); // Marshal
                let p1 = new pkg("pkgStateUpdateReceivedAck", ser);
                let bt2 = JSON.stringify(p1);
                if (bt2 == null) {
                    console.log("err.Error()");
                    return;
                }
                this.api.sendToPeer(id, bt2);
                break;
            case "pkgStateUpdateReceivedAck":
                let p2 = this.syncers[id];
                if (p2 != null) {
                    let ack = JSON.parse(inpkg.Content);
                    p2.handleAck(ack);
                }
                break;
        }
    }
    tick(ts) { this.handleTimeTick(ts); }
    handleTimeTick(ts) {
        this.currentTS = ts;
        for (let key in this.syncers) {
            let syncer = this.syncers[key];
            syncer.tick(ts);
        }
        if (this.currentTS > this.nextSendTime) {
            this.nextSendTime = this.currentTS + (3000000 + randomIntFromInterval(0, 5000000));
            this.SetState(new PeerUserState(this.Label + " says " + this.currentTS / 1000));
        }
    }
    // SetState updates this peer user data
    isendmessage(text) { this.SetState(new PeerUserState(text)); }
    SetState(p) {
        this.meshNetworkState[this.api.myID()] = new peerState(p, this.currentTS);
        this.sendDbgData();
        let serialisedState = this.meshNetworkState;
        for (let key in this.syncers) {
            let syncer = this.syncers[key];
            syncer.updateData(serialisedState);
        }
    }
}
function randomIntFromInterval(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}
let simplePeerInstance;
function letsgo(label, api) {
    simplePeerInstance = new SimplePeer1(label, api);
    return simplePeerInstance;
}
function tick(ts) {
    if (!!simplePeerInstance) {
        simplePeerInstance.handleTimeTick(ts);
        return "ok js' ticked " + ts;
    }
    return "tick can't find simplePeerInstance ";
}
function didReceiveFromPeer(peerID, data) {
    simplePeerInstance.handleMessage(peerID, data);
}
function foundPeer(peerID) {
    simplePeerInstance.handleAppearedPeer(peerID);
}
function lostPeer(peerID) {
    simplePeerInstance.handleDisappearedPeer(peerID);
}
