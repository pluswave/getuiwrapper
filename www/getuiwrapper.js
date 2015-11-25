var exec = require('cordova/exec');

var push_cbs = [];
exports.registerPushListener = function(cb){
    if( push_cbs.indexOf(cb) < 0 )
        push_cbs.push(cb);
};

exports.unregisterPushListener = function(cb){
    var index = push_cbs.indexOf(cb);

    if( index > 0 ){
        push_cbs.splice(index,1);
    }
};

exports.clearAllListeners = function(){
    push_cbs = [];
};

// 由native端调用
exports.messageReceived = function(msg){
    //
    // var object = JSON.parse(msg);
    setTimeout( function(){
        push_cbs.map( function(cb){
            cb(msg);
        });
    }, 0);
};

// JS获取ClientID
exports.getClientID = function( success, error){
    exec(success, error, "getuiwrapper", "getClientID", [] );
};

