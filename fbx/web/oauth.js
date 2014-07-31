.import fbx.async 1.0 as Async
.import "http.js" as Http
.import fbx.crypto 1.0 as Crypto

function AuthenticationFailure(value, message)
{
    Http.Failure.call(this, value, message);
}

AuthenticationFailure.prototype = new Http.Failure();
AuthenticationFailure.prototype.constructor = AuthenticationFailure;

/*
  This clas supports both OAuth-1.0a and OAuth-2.0. Options to pass
  and valid calls vary depending on version.



  OAuth-1.0a construction:

  var authz = new Client({
      version: "1.0",
      request_token_url: "...",
      authorization_url: "...",
      access_token_url: "...",
      callback_url: "...", // may be "oob"
      consumer_key: "...",
      consumer_secret: "...",

      // Optional bits, see below for defaults
      // whether to user "Authorization: OAuth" header
      use_authorization_header: true,

      // function to call to create new HTTP transactions
      http_transaction_factory: ...,

      // previously obtained access token
      access_token: "...",

      // previously obtained access token secret
      access_token_secret: "...",

      // signature method to use
      signature_method: "HMAC-SHA1",

      // whether to for use of GET on request token retrieval
      force_request_token_get: false
  });

  OAuth-2.0 construction:

  var authz = new Client({
      version: "2.0",
      authorization_url: "...",
      access_token_url: "...",
      callback_url: "...", // may be "oob" (internal shortcut for "urn:ietf:wg:oauth:2.0:oob")
      client_id: "...",
      client_secret: "...",

      // Optional bits, see below for defaults
      // whether to user "Authorization: Bearer" header
      use_authorization_header: true,

      // whether to force in-body client_secret passing on
      // access_token_url (instead of Authorization header).  OAuth-2
      // says server MUST support Authorization: Basic header, but
      // most servers don't.
      body_client_authentication: false,

      // function to call to create new HTTP transactions
      http_transaction_factory: ...,

      // previously obtained access token
      access_token: "..."
  });


  Then API flow is exactly the same:

  authz.authorizationUrlQuery().then(function (url) {
      console.log("Please redirect client to", url);
  });

  // Time passes, client authorizes application, we get callback
  // through an URL or a verifier.  If solely a verifier (oob mode),
  // use verifier as URL.

  authz.authorizationCallbackHandle(url).then(function(data) {
      // data contains additional data the server returned with access
      // token

      console.log("Client now authenticated !");
  });

  // Use client transaction factory to issue authorized API calls
  authz.http_transaction_factory({
      url: "https://api.example.com/1.0/myresource/"
  }).send().then(function(response){
      return response.jsonParse();
  }).then(function(data){
      console.log(data);
  });

  // Or stack transaction factory in another client
  var jsonRpcClient = new JsonRpc("https://api.example.com/jsonrpc.bf", [
      'my_scope.my_call',
      'my_scope.my_other_call',
  ], {
      http_transaction_factory: authz.http_transaction_factory
  });

  jsonRpcClient.my_scope.my_call().then(function(response) {
      console.log(response);
  });


  Specific calls for 2.0 only:

  // Get access token with username/password. This may not be enabled
  // to all clients
  authz.resourceOwnerCredentialsQuery(username, password).then(function (data) {
      console.log("Client authenticated");
  });

  // Get client-specific access token (for client-data access)
  authz.clientCredentialsQuery().then(function (data) {
      console.log("Client authenticated");
  });

  // Renew access token using refresh token
  authz.refreshTokenQuery().then(function (data) {
      console.log("Client access refreshed");
  });

 */
function Client(opts)
{
    if (!opts)
        return;

    for (var k in Client.default_options)
        this[k] = opts[k] !== undefined ? opts[k] : Client.default_options[k];
    this.__parent_htf = this.http_transaction_factory;

    if (this.version == "2.0" && this.callback_url == "oob")
        this.callback_url = Client.oauth2_oob_url;

    // Enforce binding of 'this' on transaction()
    this.http_transaction_factory = Client.txnFactoryCreate(this);
}

Client.default_options = {

    // 1.0, 2.0
    authorization_url: undefined,
    access_token_url: undefined,
    callback_url: undefined,
    access_token: undefined,
    use_authorization_header: true,
    http_transaction_factory: Http.Transaction.factory,
    version: "1.0",

    // 1.0
    request_token_url: undefined,
    consumer_key: undefined,
    consumer_secret: undefined,
    request_token: undefined,
    request_token_secret: undefined,
    access_token_secret: undefined,
    force_request_token_get: false,
    signature_method: "HMAC-SHA1",

    // 2.0
    client_id: undefined,
    client_secret: undefined,
    refresh_token: undefined,
    body_client_authentication: false
};

Client.urlEncode = function(x)
{
    return unescape(encodeURIComponent(x)).replace(/[^A-Z0-9~_\.-]/ig, function (ss) {
        return "%" + (0x100 + ss.charCodeAt(0)).toString(16).substr(1).toUpperCase();
    });
}

Client.prototype.toString = function()
{
    return "<OAuth " + this.version + " " + this.save() + ">";
}

Client.prototype.transactionSignatureGet = function(txn, params, secret)
{
    var method = Client.transactionMethodNormalize(txn);
    var url = Client.transactionUrlNormalize(txn);

    var parameters = Client.transactionBodyParametersGet(txn);

    txn.url.query.forEach(function(k, v) {
        parameters.push(k + "=" + Client.urlEncode(v));
    });

    for (var k in params)
        parameters.push(k + "=" + Client.urlEncode(params[k]));

    parameters.sort();

//    console.log("Parameters", JSON.stringify(parameters), parameters.join("&"))

    var blob_data = [method, url, parameters.join("&")];

    for (var i = 0; i < blob_data.length; ++i)
        blob_data[i] = Client.urlEncode(blob_data[i]);

//    console.log("Base signature string:", blob_data.join("&"))

    switch (this.signature_method) {
    case "HMAC-SHA1":
        return Crypto.HmacSha1.CryptoJS
            .HmacSHA1(blob_data.join("&"), secret)
            .toString(Crypto.HmacSha1.CryptoJS.enc.Base64);
    }
};

Client.prototype.transactionAuthenticate_1_0 = function(txn, mode, use_header, add_parameters)
{
    var parameters = {
        'oauth_consumer_key': this.consumer_key,
        'oauth_timestamp': Client.timestamp(),
        'oauth_nonce': Client.nonce(),
        'oauth_version': this.version,
        'oauth_signature_method': this.signature_method
    };

    var ap = add_parameters || {};
    for (var k in ap)
        parameters[k] = ap[k];

    var secret = "";
    switch (mode) {
    case "request_token":
        secret = encodeURIComponent(this.consumer_secret) + "&";

        if (this.callback_url)
            parameters.oauth_callback = this.callback_url;

        break;

    case "access_token":
        parameters.oauth_token = this.request_token;
        secret = encodeURIComponent(this.consumer_secret) + "&" + encodeURIComponent(this.access_token_secret);
        break;

    case "request":
        parameters.oauth_token = this.access_token;
        secret = encodeURIComponent(this.consumer_secret) + "&" + encodeURIComponent(this.access_token_secret);
        break;
    }

    if (this.realm)
        parameters.oauth_realm = this.realm;

    parameters.oauth_signature = this.transactionSignatureGet(txn, parameters, secret);

    if (use_header) {
        txn.headers.set("Authorization", "OAuth " + Http.queryStringEncode(parameters, ",", "=", '"'));
    } else {
        switch (txn.method.toLowerCase()) {
        case "delete":
        case "get": {
            for (var k in parameters)
                txn.url.query.set(k, parameters[k]);
            break;
        }

        case "put":
        case "post": {
            Client.forceFormUrlEncoded(txn);

            if (txn.headers.get("Content-type") != "application/x-www-form-urlencoded")
                return Async.Deferred.rejected(
                    "Cannot authenticate non-form data");

            txn.body = Http.QueryDict.append(txn.body, parameters);
            break;
        }

        default:
            return Async.Deferred.rejected(
                "Dont known how to inject OAuth to this request");
        }
    }

    return Async.Deferred.resolved(txn);
};

Client.txnFactoryCreate = function(self)
{
    return function(opts) { return Client._htf(self, opts); };
};

Client.prototype._requestTokenQuery = function(method, use_header)
{
    var self = this;

    var txn;

    method = method || "post";
    use_header = use_header === undefined ? true : use_header;

    if (method.toLowerCase() == "get") {
        txn = this.__parent_htf({
            method: "GET",
            url: this.request_token_url
        });
    } else {
        txn = this.__parent_htf({
            method: "POST",
            url: this.request_token_url,
            headers: {
                'content-type': "application/x-www-form-urlencoded"
            },
            body: ""
        });
    }

    this.transactionAuthenticate_1_0(txn, "request_token", use_header);

    return txn.send().then(function (response) {
        if (response.isError()) {
            if (response.status == 401)
                return new AuthenticationFailure(response.body);
            return new Http.Failure(response.status, response.statusText);
        }

        try {
            var data = Http.queryStringParse(response.body);
            if (data.oauth_token && data.oauth_token_secret) {
                self.request_token = data.oauth_token;
                self.request_token_secret = data.oauth_token_secret;
                delete data.oauth_token;
                delete data.oauth_token_secret;
                return data;
            }
        } catch (e) {
        }

        return new AuthenticationFailure(response.body);
    });
};


Client.prototype.authorizationCallbackHandle = function(url, method, use_header)
{
    var u = new Http.URL(url);
    var self = this;

    switch (this.version) {
    case "2.0": {
        switch (this.request_response_type) {
        case "code": {
            var code = url;

            if (this.callback_url != Client.oauth2_oob_url) {
                if (u.query.state != this.request_state)
                    return new AuthenticationFailure("Bad state");
                code = u.query.code;
            }

            var data = {
                grant_type: "authorization_code",
                code: code
            };

            if (this.callback_url)
                data.redirect_uri = this.callback_url;

            return this.clientAccessQuery(data);
        }

        case "token": {
            var req = new Async.Deferred.Deferred()
            req.resolve(this.handleResponse(new Http.QueryDict(u.anchor).toDict(), false));
            return req;
        }

        default:
            throw ("Unsupported request response type for this call: " + this.request_response_type);
        }
    }

    case "1.0": {
        method = method || "post";
        use_header = use_header === undefined ? true : use_header;
        var verifier = url;
        var txn;

        if (this.callback_url != "oob") {
            if (u.query.oauth_token != this.request_token)
                return new AuthenticationFailure("Bad token");
            verifier = u.query.oauth_verifier;
        }

        if (method.toLowerCase() == "get") {
            var u = new Http.URL(this.access_token_url);
            u.query.set('oauth_verifier', verifier);
            txn = this.__parent_htf({
                method: "GET",
                url: u
            });
        } else {
            txn = this.__parent_htf({
                method: "POST",
                url: this.access_token_url,
                headers: {
                    'content-type': "application/x-www-form-urlencoded"
                },
                body: "oauth_verifier="+encodeURIComponent(verifier)
            });
        }

        this.transactionAuthenticate_1_0(txn, "access_token", use_header, {oauth_verifier: verifier});

        return txn.send().then(function (response) {
            if (response.isError()) {
                if (response.status == 401)
                    return new AuthenticationFailure(response.body);
                return new Http.Failure(response.status, response.statusText);
            }

            try {
                var data = Http.queryStringParse(response.body);
                if (data.oauth_token && data.oauth_token_secret) {
                    self.access_token = data.oauth_token;
                    self.access_token_secret = data.oauth_token_secret;
                    delete self.request_token;
                    delete self.request_token_secret;
                    delete data.oauth_token;
                    delete data.oauth_token_secret;
                    return data;
                }
            } catch (e) {
                console.error("Getting access token failed", e)
            }

            return new AuthenticationFailure(response.body);
        }).thenCall(function () {
            try {
                self.changed();
            } catch (e) {}
        });
        break;
    }
    }
}

Client.prototype.authorizationUrlQuery = function(scope, response_type)
{
    switch (this.version) {
    case "1.0": {
        var self = this;

        this.request_token = this.request_token_secret = undefined;
        this.access_token = this.access_token_secret = undefined;

        return this._requestTokenQuery().then(function (data) {
            var url = new Http.URL(self.authorization_url);
            url.query.set("oauth_token", self.request_token);
            return url.toString();
        });
    }
    case "2.0": {
        var u = new Http.URL(this.authorization_url);

        response_type = response_type || "code";
        this.request_state = Client.nonce();
        this.request_response_type = response_type;

        u.query.set("response_type", response_type);
        u.query.set("state", this.request_state);
        u.query.set("client_id", this.client_id);

        if (scope)
            u.query.set("scope", scope);

        if (this.callback_url)
            u.query.set("redirect_uri", this.callback_url);

        var ret = new Async.Deferred.Deferred();
        ret.resolve(u.toString());
        return ret;
    }
    }
};

Client._htf = function(self, opts)
{
    var txn = self.__parent_htf(opts);

    txn._post_oauth_send = txn.send;
    txn.send = function() {
        if (txn.authenticated === false)
            return txn._post_oauth_send();

        var ret;

        switch (self.version) {
        case "1.0":
            ret = self.transactionAuthenticate_1_0(txn, "request", true);
            break;
        case "2.0":
            ret = self.transactionAuthenticate_2_0(txn);
            break;
        }

        if (ret)
            return ret.then(function (txn) {
                return txn._post_oauth_send();
            });
    };

    return txn;
};

Client.forceFormUrlEncoded = function(txn)
{
    var ct = txn.headers.get("Content-type");

    switch (ct) {
    case "application/x-www-form-urlencoded":
        return;

    case "application/json":
        var data = JSON.parse(txn.body);
        for (var k in data) {
            switch (typeof data[k]) {
            case "string":
            case "number":
            case "boolean":
            case "undefined":
                break;
            default: // Cant translate them
                return;
            }
        }

        var qd = new Http.QueryDict(data);

        txn.body = qd.toString();
        txn.headers.set("Content-type", "application/x-www-form-urlencoded");
        break;
    }
};

Client.prototype.transactionAuthenticate_2_0 = function(txn)
{
    var self = this;

    console.debug("Authenticating session")

    return self.ensureFreshToken().then(function () {
        if (self.use_authorization_header) {
            txn.headers.set("Authorization", "Bearer " + self.access_token);

            return txn;
        }

        switch (txn.method.toLowerCase()) {
        case "delete":
        case "get": {
            txn.url.query.set("oauth_token", self.access_token);
            break;
        }

        case "put":
        case "post": {
            Client.forceFormUrlEncoded(txn);

            if (txn.headers.get("Content-type") != "application/x-www-form-urlencoded")
                return Async.Deferred.rejected("Cannot authenticate non-form data");

            txn.body = Http.QueryDict.append(txn.body, {oauth_token: self.access_token});
            break;
        }

        default:
            return Async.Deferred.rejected(
                "Dont known how to inject OAuth to self request");
        }

        return txn;
    });
};

Client.prototype.handleAccessTokenResponse = function(response)
{
    var ct = response.headers.get("content-type");
    if (ct.match(/^text\/html/)) {
        if (response.body.charAt(0) == "{")
            ct = "application/json";
        else if (response.body.match(/&/))
            ct = "application/x-www-form-urlencoded";

        console.log("Parsing broken text/html token response as", ct)
    }

    switch (ct.split(/; /)[0]) {
    case "application/json":
        return this.handleResponse(response.jsonParse().data);
    case "application/www-form-urlencoded":
    case "application/x-www-form-urlencoded":
        return this.handleResponse(Http.queryStringParse(response.body));
    }
}

Client.prototype.handleResponse = function(response)
{
    var keys = ["access_token", "expires_in", "refresh_token", "token_type"];

    for (var i in keys) {
        var k = keys[i];

        if (response[k] === undefined)
            continue;

        this[k] = response[k];
        delete response[k];
    }

    this.last_refresh = new Date().getTime() / 1000;
    this.token_type = this.token_type || "Bearer";

    if (this.token_type.toLowerCase() != "bearer")
        throw "Unsupported token type";

    try {
        this.changed();
    } catch (e) {}

    return response;
}

Client.state_keys = {
    access_token: true,
    access_token_secret: true,
    refresh_token: true,
};

Client.prototype.save = function()
{
    var ret = {};

    for (var k in Client.state_keys)
        if (this[k] !== undefined)
            ret[k] = this[k];

    return JSON.stringify(ret);
};

Client.prototype.restore = function(st)
{
    var obj = {};
    try {
        obj = JSON.parse(st);
    } catch (e) {}

    for (var k in Client.state_keys)
        if (obj[k] !== undefined)
            this[k] = obj[k];
};

Client.prototype.ensureFreshToken = function()
{
    if (this.access_token && this.accessTokenLifetime() > 5) {
        console.debug("token is fresh")
        return Async.Deferred.resolved();
    }

    if (this.refresh_token) {
        console.debug("token is to refresh")
        return this.refreshTokenQuery();
    }

    console.debug("token is invalid")

    return Async.Deferred.rejected("No valid token");
};

Client.prototype.accessTokenLifetime = function()
{
    if (this.version != "2.0")
        throw "This method is OAuth-2 only";

    return this.last_refresh + this.expires_in - new Date().getTime() / 1000;
};

Client.prototype.clientAccessQuery = function(data)
{
    if (this.version != "2.0")
        throw "This method is OAuth-2 only";

    var self = this;
    var qd = new Http.QueryDict(data);
    var headers = {
        'content-type': 'application/x-www-form-urlencoded',
        'accept': 'application/json'
    };

    qd.set("client_id", this.client_id);

    if (this.body_client_authentication)
        qd.set("client_secret", this.client_secret);
    else
        headers.authorization = "Basic " + Qt.btoa(
            encodeURIComponent(this.client_id) + ":" +
                encodeURIComponent(this.client_secret));

    return this.__parent_htf({
        method: "POST",
        url: this.access_token_url,
        headers: headers,
        body: qd.toString()
    }).send().then(function (response) {
        return self.handleAccessTokenResponse(response);
    });
};

Client.prototype.resourceOwnerCredentialsQuery = function(username, password)
{
    return this.clientAccessQuery({
        grant_type: "password",
        username: username,
        password: password
    });
};

Client.prototype.clientCredentialsQuery = function()
{
    return this.clientAccessQuery({
        grant_type: "client_credentials",
    });
};

Client.prototype.refreshTokenQuery = function()
{
    return this.clientAccessQuery({
        grant_type: "refresh_token",
        refresh_token: this.refresh_token
    });
};

Client.oauth2_oob_url = "urn:ietf:wg:oauth:2.0:oob";
Client.nonceChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

Client.nonce = function()
{
    var r = "";

    for (var i = 0; i < 8; ++i)
        r += Client.nonceChars.charAt(Math.random() * Client.nonceChars.length);

    return r;
};

Client.timestamp = function()
{
    return "" + parseInt(new Date().getTime() / 1000);
};

Client.transactionMethodNormalize = function(txn)
{
    return (txn.method || "get").toUpperCase();
};

Client.transactionUrlNormalize = function(txn)
{
    var normalized_url = txn.url.protocol + "://" + txn.url.host;
    var implicit = {"http/80": true, "https/443": true, "http/": true, "https/": true};
    if (!implicit[txn.url.protocol.toLowerCase() + "/" + txn.url.port])
        normalized_url += ":" + txn.url.port;
    normalized_url += txn.url.path;

    return normalized_url.toLowerCase();
};

Client.transactionBodyParametersGet = function(txn)
{
    if (Client.transactionMethodNormalize(txn) != "POST"
        || txn.headers.get('Content-type') != "application/x-www-form-urlencoded"
        || !txn.body)
        return [];

    return txn.body.split(/&/g);
};
