.import "deferred.js" as Deferred

var pending = {};
var nextId = 0;

function Call(id, meth, args)
{
    Deferred.Deferred.call(this);

    this.id = id;
    this.method = meth;
    this.args = args;
}

Call.prototype = new Deferred.Deferred();
Call.prototype.constructor = Call;

Call.prototype.sendCommand = function()
{
    var data = {
        identifier: this.id,
        method: this.method,
        argCount: this.args.length
    };

    for (var i = 0; i < this.args.length; ++i)
        data["arg"+i] = this.args[i];

    self.sendMessage(data);
};

function onMessage(msg)
{
    var p = pending[msg.identifier];
    if (!p)
        return;

    delete pending[msg.identifier];

    if (msg.error)
        p.reject(msg.error);
    else
        p.resolve(msg.value);
}

function doCall(meth, args)
{
    var id = nextId++;

    var d = new Call(id, meth, args);
    d.sendCommand();
    return d;
}
