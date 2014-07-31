.pragma library

.import "rest.js" as Rest

function Failure(raw)
{
    Rest.Failure.call(this, raw.error_code, raw.msg);
    this.raw = raw;
}

Failure.prototype = new Rest.Failure();
Failure.prototype.constructor = Failure;

function Client(options)
{
    if (!options)
        return;

    Rest.Client.call(
        this,
        options.base_url || "http://mafreebox.freebox.fr/api/v1",
        options);
}

Client.prototype = new Rest.Client();
Client.prototype.constructor = Client;

Client.prototype._doCall = function()
{
    return Rest.Client.prototype._doCall.apply(this, arguments).then(function(data) {
        if (!data)
            return {};

        if (!data.success)
            return new Failure(data);

        return data.result;
    });
};
