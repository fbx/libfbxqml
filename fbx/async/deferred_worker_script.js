var handlers = {};

function sendmsg(type, data)
{
    data.type = type;
}

WorkerScript.onMessage = function(msg)
{
    try {
        var args = [];

        for (var i = 0; i < msg.argCount; ++i)
            args.push(msg["arg" + i]);

        WorkerScript.sendMessage({
            identifier: msg.identifier,
            value: handlers[msg.method].apply(undefined, args)
        });
    } catch (e) {
        WorkerScript.sendMessage({
            identifier: msg.identifier,
            error: e
        });
    }
}
