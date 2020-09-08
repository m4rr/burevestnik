log('started');
let api;
try {
  api = new MeshAPI();
}
catch(e){
  api = MeshAPI.getInstance();
}
var myId = api.getMyID();
log('my ID:', myId);

var currentTS = 0;
var meshNetworkState = {};
var syncers = {};

function newPeerToPeerSyncer(sender_func) {
    var s = {};
    s.lastAttemptTS = 0;
    s.lastTickTime = 0;
    s.synced = true;
  s.delay = 30000;
    s.updatePkg = {TS: 0, Data: ""};
    
    s.sender = sender_func;

    s.updateData = function(obj) {
        s.synced = false;
        s.lastAttemptTS = 0;
        s.updatePkg.Data = obj;
        s.updatePkg.TS = s.lastTickTime;
        s.tick(s.lastTickTime)
    };

    s.tick = function(ts) {
        if(!s.synced && ts-s.lastAttemptTS >= s.delay) {
            s.lastAttemptTS = ts;
            s.sender(s.updatePkg);
        }
        s.lastTickTime = ts;
    }

    s.handleAck = function(ackPkg) {
        if(s.synced == true) {
            return;
        }
        if(ackPkg.TS == s.updatePkg.TS) {
            s.synced = true;
        }
    };

    return s;
}

api.registerPeerAppearedHandler(function(id) {
    syncers[id] = newPeerToPeerSyncer(function(pkgStateUpdate){
        var p = {
            Type: "pkgStateUpdate",
            Content: pkgStateUpdate
        }
        api.sendMessage(id, JSON.stringify(p));
    });
    if(Object.keys(meshNetworkState).length > 0) {
    syncers[id].updateData(meshNetworkState);
    }
});

api.registerPeerDisappearedHandler(function(id) {
    delete syncers[id];
});

function sendDbgData() {
    api.setDebugMessage(JSON.stringify({
    MyID: myId,
    MyTS: currentTS,
    PeersState: meshNetworkState
  }))
}

function handleNewIncomingState(sourceID, update) {
    var newNetworkState = update.Data;
  var somethingChanged = false;
    for(var id in newNetworkState) {
        var newPeerState = newNetworkState[id];
        if(meshNetworkState[id] == undefined) {
            somethingChanged = true;
            meshNetworkState[id] = newPeerState;
        } else {
            var existingPeerState = meshNetworkState[id];
            if(existingPeerState.UpdateTS < newPeerState.UpdateTS) {
                somethingChanged = true
                meshNetworkState[id] = newPeerState
            }
        }
    }

  if(somethingChanged == true) {
    sendDbgData()
    for(var id in syncers) {
      if(sourceID == id) {
        continue
      }
      syncers[id].updateData(meshNetworkState)
    }
  }
}


api.registerMessageHandler(function(id, data) {
    try {
        var inpkg = JSON.parse(data);
    }
    catch(e) {
        return;
    }
  switch(inpkg.Type) {
  case "pkgStateUpdate":
    var update = inpkg.Content;
        handleNewIncomingState(id, update)

    var ack = {}
    ack.TS = update.TS;
    var p = {Type: "pkgStateUpdateReceivedAck", Content: ack};
    api.sendMessage(id, JSON.stringify(p));
    break;
  case "pkgStateUpdateReceivedAck":
    if(syncers[id] != undefined){
      var ack = inpkg.Content;
      syncers[id].handleAck(ack);
    }
    break;
  }
});


function handleUserData(userDataObject) {
    meshNetworkState[myId] = {
    UserState: userDataObject,
    UpdateTS:  currentTS
    };
  sendDbgData();
  for(var id in syncers) {
    syncers[id].updateData(meshNetworkState)
  }
}

var nextTestSendTime = 0;
api.registerTimeTickHandler(function(ts) {
    currentTS = ts;

    for(var id in syncers) {
        syncers[id].tick(ts);
    }

    if(currentTS > nextTestSendTime) { //debug
        nextTestSendTime = currentTS + 5e6;
        handleUserData({Message: myId + " says " + (currentTS/1000.0).toFixed(0)})
    }
});

api.registerUserDataUpdateHandler(handleUserData); // This will be called from frontend
