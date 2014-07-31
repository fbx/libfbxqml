.pragma library

.import fbx.async 1.0 as Async
.import "http.js" as Http

function Failure(value, message)
{
    this.value = value;
    this.message = message;
}

Failure.prototype = new Async.Deferred.Failure();
Failure.prototype.constructor = Failure;

function Resource(name, opts)
{
    this._name = name;
    this._opts = opts || {};
    this._url = this._opts.url || name;
}

Resource.prototype.toString = function()
{
    return "<" + this._name + ">";
}

Resource.prototype.add = function(name, opts)
{
    this[name] = new Resource(name, opts)
}

/*
  Resource proxys serve different purposes. Suppose a client that was
  declared with:

  var c = new Client();
  c.add("resource");
  c.resource.add("subresource");

  can be used as:

  c.resource.read()                       -> GET /resource
  c.resource(42).read()                   -> GET /resource/42
  c.resource.subresource.create()         -> POST /resource/subresource
  c.resource().subresource.create()       -> POST /resource/subresource
  c.resource(42).subresource(1).destroy() -> DELETE /resource/42/subresource/1

  c.resource, c.resource(42) and c.resource.subresource are resource proxies.

  On a resource proxy, different actions are available:

  - simple dereferencing for subresources, like c.resource.subresource;
    this yields another resource proxy for subresource.

  - object ID specification through call, like c.resource(42);
    this yields another resource proxy for the same resource, but with
    ID sepcified.

  - action, like c.resource.read() or c.resource(42).subresource.create({...}).

  - subresource registration, like c.resource.add("subresource").

  This means mkResourceProxy() has to generate an object that is both
  a function and an object with additional methods for
  subresources, .add() and actions.

  We could create the whole subtree statically, but this could be
  potentially big (and slow) to create.  Take into account that a new
  subtree has to be generated each time a specific ID is set on a
  node. (i.e. each time resource() is called).

  Here, we abuse javascript property getters to yield a new resource
  proxy on demand, only when necessary.

  Primary proxy type is a function, this is the only way to make an
  object callable in JS.  We can attach properties afterwards.

  @param backend Backend object
  @param path_ A list of Resource objects
  @param values_ A list of IDs to associate to each resource object.
                 IDs can be undefined.
 */
function mkResourceProxy(backend, path_, values_)
{
    /* Take copies into this closure */
    var path = path_.slice();
    var values = values_.slice();
    var last = path[path.length - 1];

    /*
      proxy(id) returns a clone of itself where last value (i.e. ID)
      is set.

      This makes proxy(a)(b)(c) possible. This becomes an useless
      alias to proxy(c).
     */
    var proxy = function(id) {
        return mkResourceProxy(backend, path, [].concat(values.slice(0, -1), [id]));
    }

    /*
      add() must both declare the new resource in the backend resource
      tree and attach the subresource proxy to its parent proxy.
     */
    proxy.add = function(name, opts) {
        last.add(name, opts);

        Object.defineProperty(proxy, name, {
            get: function() {
                return mkResourceProxy(
                    backend, [].concat(path, [last[name]]), [].concat(values, [undefined]))
            }
        });
    }

    proxy.toString = function() {
        return "<Proxy for " + backend + " " + path + ">";
    }

    /*
      Register existing subresources from backend model.
     */
    Object.keys(last).forEach(function(k) {
        if (k.charAt(0) == "_" || k == "toString" || k == "add")
            return;

        Object.defineProperty(proxy, k, {
            get: function() {
                return mkResourceProxy(
                    backend, [].concat(path, [last[k]]), [].concat(values, [undefined]))
            }
        });
    })

    /*
      Register actions.
     */
    Object.keys(backend._actions).forEach(function(k) {
        proxy[k] = function(obj, params) {
            var u = backend._url(path, values, params);

            if (backend._actions[k].url)
                return u.url;

            return backend._doCall(k, u, obj);
        }
    });

    return proxy;
}

function Client(baseUrl, options)
{
    this._opts = {}

    options = options || {};
    for (var k in Client.defaults)
        this._opts[k] = options[k] !== undefined ? options[k] : Client.defaults[k];

    this._baseUrl = baseUrl;
    this._resources = {};

    this._actions = {
        create: {method: "POST", hasQueryBody: true},
        read: {method: "GET", hasQueryBody: false, isRead: true},
        update: {method: "PUT", hasQueryBody: true},
        destroy: {method: "DELETE", hasQueryBody: false},
        url: {url: true}
    };
}

Client.defaults = {
    suffix: "/",
    http_transaction_factory: Http.Transaction.factory,
    authenticated: true,
    authenticatedRead: true,
    cached: undefined
};

Client.prototype.addVerb = function(action, method, hasQueryBody)
{
    this._actions[action] = {
        method: method,
        hasQueryBody: hasQueryBody
    };
};

Client.prototype.add = function(name, opts)
{
    var r = new Resource(name, opts);
    this._resources[name] = r;
    this[name] = mkResourceProxy(this, [r], [undefined]);
};

/*
  Get URL infos

  @param path A list of Resources, in order
  @param values A list of IDs to associate to resources
  @param opts Options specific to this call
*/
Client.prototype._url = function(path, values, opts)
{
    var self = this;

    var opt = function(x) {
        if (opts && opts[x] !== undefined)
            return opts[x];
        if (path[path.length - 1]._opts[x] !== undefined)
            return path[path.length - 1]._opts[x];
        if (self._opts[x] !== undefined)
            return self._opts[x];
        return undefined;
    }

    var url = this._baseUrl;

    for (var i = 0; i < path.length; ++i) {
        url += "/" + path[i]._url;
        if (values[i] !== undefined)
            url += "/" + values[i];
    }

    url += opt("suffix");

    return {opt: opt, url: url};
};

/*
  Do the actual RESTful call.

  @param action One of declared actions
  @param data Optional data to POST, PUT, etc.

  Options are taken, in order of precedence, in opts, then in resource
  options, then in client options.
*/
Client.prototype._doCall = function(action, urlInfo, data)
{
    var self = this;
    var actionInfo = this._actions[action];

    data = data || {};

    var txn = this._opts.http_transaction_factory({
        method: actionInfo.method,
        headers: {
            "accept": "application/json"
        },
        url: urlInfo.url,
        authenticated: actionInfo.isRead
            ? urlInfo.opt("authenticatedRead")
            : urlInfo.opt("authenticated"),
        cached: urlInfo.opt("cached")
    });

    if (actionInfo.hasQueryBody) {
        var ct = urlInfo.opt("content-type") || "application/json";
        switch (ct) {
        case "application/json":
            txn.body = JSON.stringify(data);
            break;
        case "application/x-www-form-urlencoded":
            txn.body = new Http.QueryDict(data).toString();
            break;
        default:
            throw "Unable to encode body to " + ct;
        }

        txn.headers['content-type'] = ct;
    } else if (data)
        txn.url.query.append(data);

    return txn.send().then(
        function (response) {
            var rsp = response.jsonParse();
            if (Async.Deferred.is_failure(rsp))
                return rsp;
            return rsp.data;
        }
    );
};

Client.prototype.toString = function()
{
    return "<Rest client " + this._baseUrl + ">";
}
