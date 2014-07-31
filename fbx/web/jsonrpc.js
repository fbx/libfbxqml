.pragma library

.import "http.js" as Http
.import fbx.async 1.0 as Async

function Client(baseUrl, methods, opts)
{
    var self = this;

    opts = opts || {};

    this.http_transaction_factory = opts.http_transaction_factory || Http.Transaction.factory;

    this.baseUrl = baseUrl;
    this.queryId = 0;

    methods.forEach(function(name) {
        var base = self;
        var parts = name.split(/\./);

        for (var i = 0; i < parts.length - 1; ++i) {
            var part = parts[i];

            if (base[part] === undefined)
                base[part] = {};

            base = base[part];
        }

        base[parts[parts.length - 1]] = Client.callCreate(self, name);
    });
}

Client.callCreate = function(self, name)
{
    var f = function(params) {
        return self.callDo(name, params);
    };

    return f;
};


Client.prototype.queryIdGet = function()
{
    var id = this.queryId++;
    return "query-" + id;
};

function Failure(value)
{
    this.value = value;
}

Failure.prototype = new Async.Deferred.Failure();
Failure.prototype.constructor = Failure;

Client.prototype.callDo = function(name, params)
{
    params = params || {};

    var request = {
        "jsonrpc": "2.0",
        "id": this.queryIdGet(),
        "method": name,
        "params": params
    };

    return this.http_transaction_factory({
        url: this.baseUrl,
        headers: {
            "content-type": 'application/json'
        },
        body: JSON.stringify(request),
        method: "POST"
    }).send().then(function (response) {
        return response.jsonParse();
    }).then(function(response) {
        if (response.data.error)
            return new Failure(response.data.error);

        return response.data.result;
    });
};
