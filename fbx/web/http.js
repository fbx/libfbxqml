.pragma library
.import fbx.async 1.0 as Async
.import "parseuri.js" as ParseUri

var Failure = function(value, message)
{
    this.value = value;
    this.message = message;
};

Failure.prototype = new Async.Deferred.Failure();
Failure.prototype.constructor = Failure;

var JsonDecodeFailure = function(value)
{
    this.value = value;
};

JsonDecodeFailure.prototype = new Async.Deferred.Failure();
JsonDecodeFailure.prototype.constructor = JsonDecodeFailure;

var XmlDecodeFailure = function(value)
{
    this.value = value;
};

XmlDecodeFailure.prototype = new Async.Deferred.Failure();
XmlDecodeFailure.prototype.constructor = XmlDecodeFailure;


var HeaderDict = function(headers)
{
    var self = this;

    if (headers instanceof HeaderDict)
        headers.forEach(function(k, v) {
            self.set(k, v);
        });
    else
        for (var k in headers)
            this.set(k, headers[k]);
};

HeaderDict.prototype.set = function(k, v)
{
    if (v === undefined)
        return this.unset(k);

    this[k.toLowerCase()] = v;
};

HeaderDict.prototype.unset = function(k)
{
    delete this[k.toLowerCase()];
};

HeaderDict.prototype.get = function(k)
{
    return this[k.toLowerCase()];
};

HeaderDict.prototype.keys = function(k)
{
    var keys = [];

    for (var k in this)
        if (this.hasOwnProperty(k))
            keys.push(k);

    return keys;
};

HeaderDict.prototype.forEach = function(f)
{
    for (var k in this)
        if (this.hasOwnProperty(k))
            f(k, this[k]);
};



var QueryDict = function(values)
{
    var self = this;

    if (values instanceof QueryDict)
        values.forEach(function(k, v) {
            self.set(k, v, true);
        });
    else if ('string' === typeof values)
        this.parse(values);
    else
        for (var k in values)
            this.set(k, values[k]);
};

QueryDict.prototype.set = function(k, v, append)
{
    if (v === undefined)
        return this.unset(k);

    if (this[k] === undefined || !append)
            this[k] = [];

    this[k].push("" + v);
};

QueryDict.prototype.unset = function(k)
{
    delete this[k];
};

QueryDict.prototype.get = function(k)
{
    try {
        return this[k][0];
    } catch (e) {
        return undefined;
    }
};

QueryDict.prototype.getAll = function(k)
{
    return this[k];
};

QueryDict.prototype.keys = function(k)
{
    var keys = [];

    for (var k in this)
        if (this.hasOwnProperty(k))
            keys.push(k);

    return keys;
};

QueryDict.prototype.forEach = function(f)
{
    for (var k in this)
        if (this.hasOwnProperty(k))
            for (var kk in this[k])
                f(k, this[k][kk]);
};

QueryDict.prototype.parse = function(str)
{
    var self = this;

    str.replace(/(?:^|&)([^&=]*)=?([^&]*)/g, function(sep, k, v) {
		if (k)
            self.set(k, decodeURIComponent(v.replace(/\+/g, " ")), true);
	});
}

QueryDict.prototype.toString = function(sep)
{
    var r = [];

    this.forEach(function(k, v) {
        r.push(encodeFormComponent(k, v));
    });

    return r.join(sep || "&");
}

QueryDict.prototype.toDict = function()
{
    var r = {};

    this.forEach(function(k, v) {
        r[k] = v;
    });

    return r;
}

QueryDict.prototype.append = function(args)
{
    var self = this;
    args = new QueryDict(args);

    args.forEach(function(k, v) {
        self.set(k, v);
    });
}

QueryDict.append = function(existing, args)
{
    var args = new QueryDict(args).toString();
    if (existing && args)
        return existing + "&" + args;
    else if (existing)
        return existing;
    else
        return args;
}



var URL = function(url)
{
    if (url instanceof URL) {
        for (var k in ParseUri.parseUri.options.key)
            this[ParseUri.parseUri.options.key[k]] = url[ParseUri.parseUri.options.key[k]];
        this.query = new QueryDict(url.query);
    } else {
        var u = ParseUri.parseUri(url);
        for (var k in ParseUri.parseUri.options.key)
            this[ParseUri.parseUri.options.key[k]] = u[ParseUri.parseUri.options.key[k]];
        this.query = new QueryDict(u.query);
    }
};

URL.prototype.toString = function()
{
    var r = "";
    var qs = this.query.toString();

    if (this.protocol)     r += this.protocol + ":";
    if (this.host) {
        r += "//";
        if (this.user)     r += this.user;
        if (this.password) r += "@" + this.password;
        if (this.user || this.password)
            r += ":";
        r += this.host;
        if (this.port)     r += ":" + this.port;
    }
    r += this.path;

    if (qs)                r += "?" + qs;
    if (this.anchor)       r += "#" + this.anchor;

    return r;
};

URL.prototype.relative = function(relpath)
{
    var u = new URL(relpath);
    if (u.protocol)
        return u;

    if (u.host) {
        u.protocol = this.protocol;
        return u;
    }

    var ret = new URL(this);

    if (relpath.charAt(0) != "/" && ret.path.match(/\//))
        ret.path = ret.path.replace(/\/[^\/]*$/, relpath);
    else
        ret.path = relpath;
    ret.anchor = "";

    return ret;
};



var Request = function(method, url, headers)
{
    Async.Deferred.Deferred.call(this, function(self)
                  {
                      self.__client.onreadystatechange = undefined;
                      self.__client.abort();
                      self.__client = undefined;
                  });

    this.method = method;
    this.url = url;
    this.headers = new HeaderDict(headers);

    this.__client = new XMLHttpRequest;
    this.__client.open(method, url);
    this.__client.onreadystatechange = Request._makeStateHandler(this);

    var self = this;

    this.headers.forEach(function(k, v) {
        self.__client.setRequestHeader(k, v);
    });
};

Request.prototype = new Async.Deferred.Deferred();
Request.prototype.constructor = Request;

Request.prototype.print = function(body)
{
    console.log("OUT| "+this.method + " " + this.url + " HTTP/1.1");

    this.headers.forEach(function(k, v) {
        console.log("OUT| " + k + ": " + v);
    });

    console.log("OUT| ");
    console.log("OUT| " + (body || "").split("\n").join("\nOUT| "));
    console.log("");
};

Request.prototype.send = function(body)
{
    this.__client.send(body);

    return this;
};

Request._makeStateHandler = function(self)
{
    return function (e) {self.stateChanged(e);};
};

Request.prototype.stateChanged = function(e)
{
    if (this.__client.readyState != XMLHttpRequest.DONE)
        return;

    this.resolve(this.makeResponseObject());
}


Request.prototype.makeResponseObject = function()
{
    var status = this.__client.status;
    var statusText = this.__client.statusText;
    var headers = new HeaderDict();
    var body = this.__client.responseText;

    var hlist = this.__client.getAllResponseHeaders().split("\r\n");

    for (var i = 0; i < hlist.length; ++i) {
        var ki = hlist[i].indexOf(": ");
        if (ki < 0)
            continue;

        headers.set(
            hlist[i].substr(0, ki),
            hlist[i].substr(ki + 2));
    }

    var rsp = new Response(status, statusText, headers, body);
    rsp._xhr = this.__client;
    return rsp;
};


var Response = function(status, statusText, headers, body)
{
    this.status = parseInt(status);
    this.statusText = statusText;
    this.headers = new HeaderDict(headers);
    this.body = body;
};

Response.prototype.print = function()
{
    console.log(" IN| HTTP/1.1 " + this.status + " " + this.statusText);
    this.headers.forEach(function(k, v) {
        console.log(" IN| " + k + ": " + v);
    });
    console.log(" IN|");
    console.log(" IN| " + (this.body || "").split("\n").join("\n IN| "));
    console.log("");
};

Response.prototype.isError = function()
{
    return this.status >= 400;
};

Response.prototype.jsonParse = function(accept_null)
{
    if (this.isError())
        return new Failure(this.status, this.statusText);

    if (!this.body && !accept_null)
        return new JsonDecodeFailure(this.body);

    try {
        var data = null;
        if (this.body)
            data = JSON.parse(this.body);
        return new JsonResponse(
            this.status, this.statusText, this.headers,
            this.body, data);
    } catch (e) {
        return new JsonDecodeFailure(this.body);
    }
};

Response.prototype.xmlParse = function(accept_null)
{
    if (this.isError())
        return new Failure(this.status, this.statusText);

    if (!this.body && !accept_null)
        return new XmlDecodeFailure(this.body);

    try {
        return new XmlResponse(
            this.status, this.statusText, this.headers,
            this._xhr.responseXML.documentElement);
    } catch (e) {
        return new XmlDecodeFailure(this.body);
    }
};


var JsonResponse = function(status, statusText, headers, body, data)
{
    Response.call(this, status, statusText, headers);
    this.data = data;
};

JsonResponse.prototype = new Response(0, "", {}, "");
JsonResponse.prototype.constructor = JsonResponse;


var XmlResponse = function(status, statusText, headers, document)
{
    Response.call(this, status, statusText);
    this.document = document;
};

XmlResponse.prototype = new Response(0, "", {}, null);
XmlResponse.prototype.constructor = XmlResponse;


var Transaction = function(args)
{
    this.url = new URL(args.url || "");
    this.headers = new HeaderDict(args.headers || {});
    this.method = args.method || "GET";
    this.body = args.body || "";
    this.debug = !!args.debug;

    for (var k in args)
        if (!k.match(/^(url|headers|method|body|debug)$/))
            this[k] = args[k];
};

Transaction.factory = function(args)
{
    return new Transaction(args);
};

Transaction.debug_factory = function(args)
{
    args.debug = true;
    return Transaction.factory(args);
};

Transaction.prototype.send = function()
{
    var query = new Request(this.method, this.url.toString(), this.headers);

    if (this.debug)
        query.print(this.body);

    query.send(this.body)

    if (this.debug)
        query = query.thenCall(function(response) {response.print()});

    return query;
};

Transaction.prototype.toString = function()
{
    return "<HTTP " + this.method + " " + this.url + ">";
};

Transaction.prototype.methodGet = function()
{
    return this.method;
};



var encodeFormComponent = function(key, value, k_v_separator, v_quote)
{
    k_v_separator = k_v_separator || "=";
    v_quote = v_quote || "";

    var k = encodeURIComponent(key);

    if (value === undefined)
        return k;

    var v = encodeURIComponent(value).replace(/%20/g, "+");

    return k + '=' + v_quote + v + v_quote;
};

var queryStringEncode = function(data, separator, k_v_separator, v_quote)
{
    separator = separator || "&";
    data = data || {};

    var postarray = [];

    for (var k in data)
        postarray.push(encodeFormComponent(k, data[k], k_v_separator, v_quote));

    return postarray.join(separator);
};

var queryStringParse = function(s, separator, k_v_separator)
{
    separator = separator || "&";
    k_v_separator = k_v_separator || "=";

    var components = s.split(separator);
    var data = {};

    for (var i = 0; i < components.length; ++i) {
        var kv = components[i].split(k_v_separator);
        switch (kv.length) {
        case 1:
            data[decodeURIComponent(kv[0])] = undefined;
            break;
        case 2:
            data[decodeURIComponent(kv[0])] = decodeURIComponent(kv[1].replace(/\+/g, " "));
            break;
        default:
            continue;
        }
    }

    return data;
};



var CacheEntry = function(cache, txn, response)
{
    this.cache = cache;
    this.serial = cache.serial++;
    this.response = response;
    this.createTime = new Date().getTime();
    this.expire = this.createTime + 3600000;
    this.vary = [];
    this.url = txn.url.toString();
    this.forced = txn.cached === true;

    var cc = response.headers.get("cache-control");
    if (cc) {
        var e = cc.match(/max-age=([0-9-]*)/);
        this.expire = new Date().getTime() + parseInt(e) * 1000;
    }

    var expires = response.headers.get("expires");
    if (expires)
        this.expire = Date.parse(expires);

    var vary = response.headers.get("vary");
    if (vary)
        this.vary = vary.split(/, */);

    this.original_headers = {};
    for (var k in this.vary)
        this.original_headers[k] = txn.headers.get(k);

    this.log("New entry ", txn.url.toString());
    this.log("Expires on: ", this.expire, "(" + ((this.expire - this.createTime) / 1000) + "s)", this.forced ? "forced" : "");
    this.log("Varies on: ", this.vary.join(", "));
};

CacheEntry.prototype.isCachable = function()
{
    var _pragma = this.response.headers.get("pragma") || "";
    if (_pragma.match(/no-cache/))
        return false;

    var cc = this.response.headers.get("cache-control");
    if (cc) {
        cc = cc.split(/, */);
        for (var i in cc) {
            var kv = cc[i].match(/([a-z-]+)(=(.*))?/);

            switch (kv[1]) {
            case "max-age": {
                var age = parseInt(kv[3]);
                if (age > 0)
                    break;
            } // fallthrough
            case "must-revalidate": // Let Qt cache handle this
            case "no-cache":
            case "no-store":
                return false;
            }
        }
    }

    return true;
};

CacheEntry.prototype.isExpired = function()
{
    return this.expire < new Date().getTime() && !this.forced;
};

CacheEntry.prototype.matches = function(txn)
{
    if (txn.url.toString() != this.url)
        return;

    for (var k in this.vary)
        if (this.original_headers[k] != txn.headers.get(k))
            return false;

    return !this.isExpired();
};

CacheEntry.prototype.log = function()
{
    var args = [this.serial];
    for (var i = 0; i < arguments.length; ++i)
        args.push(arguments[i]);
    this.cache.log.apply(this.cache, args);
};



var Cache = function (opts)
{
    this.opts = {};
    this.serial = 0;

    opts = opts ||{};

    for (var k in Cache.defaults)
        this.opts[k] = opts[k] === undefined ? Cache.defaults[k] : opts[k];

    this.cache = {};

    var self = this;
    this.http_transaction_factory = function(args) {
        return Cache._htf(self, args)
    };
};

Cache.defaults = {
    http_transaction_factory: Transaction.factory,
    debug: false
};

Cache.key = function(txn)
{
    return Qt.md5(txn.protocol + "|" + txn.url.host + "|" + txn.url.port + "|" + txn.url.path);
};

Cache.prototype.gc = function()
{
    for (var key in this.cache) {
        for (var i = this.cache[key].length - 1; i >= 0; --i) {
            var entry = this.cache[key][i];

            if (entry.isExpired()) {
                entry.log("Dropped");
                this.cache[key].splice(i, 1);
            }
        }
    }
};

Cache.prototype.handleResponse = function(txn, response)
{
    var entry = new CacheEntry(this, txn, response);

    if (!entry.isCachable() && txn.cached !== true)
        return;

    var key = Cache.key(txn);
    if (!this.cache[key])
        this.cache[key] = [];

    this.cache[key].push(entry);

    this.gc();
};

Cache.prototype.log = function()
{
    if (!this.opts.debug)
        return;

    var args = ["HTTP Cache"];
    for (var i = 0; i < arguments.length; ++i)
        args.push(arguments[i]);

    console.log(args.join(" "));
}

Cache._htf = function(self, args)
{
    var txn = self.opts.http_transaction_factory(args);

    txn.__cache_send = txn.send;

    txn.send = function() {
        if (self.cached === false)
            return txn.__cache_send();

        return self.cachedSend(txn);
    };

    return txn;
};

Cache.prototype.cachedSend = function(txn)
{
    var self = this;
    var key = Cache.key(txn);

    if (this.cache[key]) {
        if (txn.method.toLowerCase() != "get") {
            self.log(
                txn.url.toString(), "cleared by", txn.method,
                this.cache[key].length, "entries cleared");
            delete this.cache[key];
        } else {
            for (var i in this.cache[key]) {
                var entry = this.cache[key][i];

                if (!entry.matches(txn)) {
                    continue;
                }

                entry.log("Hits,", txn.url);

                return Async.Deferred.resolved(entry.response);
            }
        }
    }

    self.log(txn.url.toString(), "not in cache, fetching");

    return txn.__cache_send.call(txn).thenCall(function(response) {
        self.log(txn.url.toString(), "Got a response", response.isError());
        if (!response.isError())
            self.handleResponse(txn, response);
    });
};
