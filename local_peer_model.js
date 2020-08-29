var pkgStateUpdate = /** @class */ (function () {
    function pkgStateUpdate() {
    }
    return pkgStateUpdate;
}());
var pkgStateUpdateReceivedAck = /** @class */ (function () {
    function pkgStateUpdateReceivedAck() {
    }
    return pkgStateUpdateReceivedAck;
}());
var pkg = /** @class */ (function () {
    function pkg(Type, Content) {
        this.Type = Type;
        this.Content = Content;
    }
    return pkg;
}());
var debugDataStruct = /** @class */ (function () {
    function debugDataStruct(MyID, MyTS, PeersState) {
        this.MyID = MyID;
        this.MyTS = MyTS;
        this.PeersState = PeersState;
    }
    return debugDataStruct;
}());
var peerToPeerSyncer = /** @class */ (function () {
    function peerToPeerSyncer(sender) {
        this.lastAttemptTS = 0;
        this.lastTickTime = 0;
        this.synced = true;
        this.delay = 30000;
        this.sender = sender;
        this.updatePkg = new pkgStateUpdate();
    }
    peerToPeerSyncer.prototype.updateData = function (data) {
        this.synced = false;
        this.lastAttemptTS = 0;
        this.updatePkg.Data = data;
        this.updatePkg.TS = this.lastTickTime;
        this.tick(this.lastTickTime);
    };
    peerToPeerSyncer.prototype.tick = function (ts) {
        if (!this.synced && ts - this.lastAttemptTS >= this.delay) {
            this.lastAttemptTS = ts;
            this.sender(this.updatePkg);
        }
        this.lastTickTime = ts;
    };
    peerToPeerSyncer.prototype.handleAck = function (ackPkg) {
        if (this.synced) {
            return;
        }
        if (ackPkg.TS == this.updatePkg.TS) {
            this.synced = true;
        }
    };
    return peerToPeerSyncer;
}());
// PeerUserState contains user data
var PeerUserState = /** @class */ (function () {
    function PeerUserState(Message) {
        this.Message = Message;
    }
    return PeerUserState;
}());
var peerState = /** @class */ (function () {
    function peerState(UserState, UpdateTS) {
        this.UserState = UserState;
        this.UpdateTS = UpdateTS;
    }
    return peerState;
}());
// SimplePeer1 provides simplest flood peer strategy
var SimplePeer1 = /** @class */ (function () {
    // NewSimplePeer1 returns new SimplePeer
    function SimplePeer1(label, api) {
        var _this = this;
        this.api = api;
        this.Label = label;
        this.syncers = {};
        this.meshNetworkState = {};
        api.RegisterMessageHandler(function (id, data) {
            _this.handleMessage(id, data);
        });
        api.RegisterPeerAppearedHandler(function (id) {
            _this.handleAppearedPeer(id);
        });
        api.RegisterPeerDisappearedHandler(function (id) {
            _this.handleDisappearedPeer(id);
        });
        api.RegisterTimeTickHandler(function (ts) {
            _this.handleTimeTick(ts);
        });
    }
    // HandleAppearedPeer implements crowd.MeshActor
    SimplePeer1.prototype.handleAppearedPeer = function (id) {
        var _this = this;
        this.syncers[id] = new peerToPeerSyncer(function (d) {
            var bt = JSON.stringify(d);
            if (bt == null) {
                console.log("err.Error()");
                return;
            }
            var p = new pkg("pkgStateUpdate", bt);
            var bt2 = JSON.stringify(p);
            if (bt2 == null) {
                console.log("err.Error()");
                return;
            }
            _this.api.SendMessage(id, bt2);
        });
        if (Object.keys(this.meshNetworkState).length > 0) {
            var serialisedState = JSON.stringify(this.meshNetworkState);
            if (serialisedState == null) {
                console.log("err.Error()");
                return;
            }
            this.syncers[id].updateData(serialisedState);
        }
    };
    SimplePeer1.prototype.handleDisappearedPeer = function (id) {
        delete this.syncers[id];
    };
    SimplePeer1.prototype.sendDbgData = function () {
        this.api.SendDebugData(new debugDataStruct(this.api.GetMyID(), this.currentTS, this.meshNetworkState));
    };
    SimplePeer1.prototype.handleNewIncomingState = function (sourceID, update) {
        var newNetworkState = JSON.parse(update.Data);
        var somethingChanged = false;
        if (newNetworkState != null) {
            for (var key in newNetworkState) {
                var newPeerState = newNetworkState[key];
                var existingPeerState = this.meshNetworkState[key];
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
            var serialisedState = JSON.stringify(this.meshNetworkState);
            if (serialisedState == null) {
                console.log("err.Error()");
                return;
            }
            for (var key in this.syncers) {
                var syncer = this.syncers[key];
                if (sourceID == key) {
                    continue;
                }
                syncer.updateData(serialisedState);
            }
        }
    };
    SimplePeer1.prototype.handleMessage = function (id, data) {
        // let inpkg = new pkg()
        var inpkg = JSON.parse(data); // Unmarshal
        if (inpkg == null) {
            console.log("err.Error()");
            return;
        }
        switch (inpkg.Type) {
            case "pkgStateUpdate":
                var update = JSON.parse(inpkg.Content); // Unmarshal
                this.handleNewIncomingState(id, update);
                var ack = new pkgStateUpdateReceivedAck();
                ack.TS = update.TS;
                var ser = JSON.stringify(ack); // Marshal
                var p1 = new pkg("pkgStateUpdateReceivedAck", ser);
                var bt2 = JSON.stringify(p1);
                if (bt2 == null) {
                    console.log("err.Error()");
                    return;
                }
                this.api.SendMessage(id, bt2);
                break;
            case "pkgStateUpdateReceivedAck":
                var p2 = this.syncers[id];
                if (p2 != null) {
                    var ack_1 = JSON.parse(inpkg.Content);
                    p2.handleAck(ack_1);
                }
                break;
        }
    };
    SimplePeer1.prototype.handleTimeTick = function (ts) {
        this.currentTS = ts;
        for (var key in this.syncers) {
            var syncer = this.syncers[key];
            syncer.tick(ts);
        }
        if (this.currentTS > this.nextSendTime) {
            this.nextSendTime = this.currentTS + (3000000 + randomIntFromInterval(0, 5000000));
            this.SetState(new PeerUserState(this.Label + " says " + this.currentTS / 1000));
        }
    };
    // SetState updates this peer user data
    SimplePeer1.prototype.SetState = function (p) {
        this.meshNetworkState[this.api.GetMyID()] = new peerState(p, this.currentTS);
        this.sendDbgData();
        var serialisedState = this.meshNetworkState;
        for (var key in this.syncers) {
            var syncer = this.syncers[key];
            syncer.updateData(serialisedState);
        }
    };
    return SimplePeer1;
}());
function randomIntFromInterval(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min);
}
//# sourceMappingURL=local_peer_model.js.map