.import fbx.async 1.0 as Async
.import "http.js" as Http
.import "freeboxos.js" as FreeboxOS
.import fbx.crypto 1.0 as Crypto

function Failure(value, message)
{
    Http.Failure.call(this, value, message);
};

Failure.prototype = new Http.Failure();
Failure.prototype.constructor = Failure;

/*
  var authz = new FreeboxOSAuth.Client({
      app_id: "...",
      app_name: "...",
      app_version: "...",
      device_name: "...",

      // function to call to create new HTTP transactions
      http_transaction_factory: ...,

      // previously obtained token
      app_token: "...",
  });


  Then API flow is:

  authz.query().then(function () {
      // Tell user to go press button on Freebox Server
  });

  // Time passes, client polls whether authorization was accepted
  authz.check().then(function(status) {
      console.log("Authorization status:", status);
      switch (status) {
      case "unknown":
      case "denied":
      case "timeout":
          // warn user, bail out
          return;

      case "pending":
          // still waiting
          return;

      case "granted":
          // yay !
          return;
      }
  });

  As a shortcut, you can call authz.registerPolled(tq, timeout) with a
  TimeQueue instance and a global timeout to wait response for.  It
  does the registration query and the waiting for you.

  // Tell user to go press the Server button
  authz.register(tq, 30000).then(function(status) {
      // OK !
  }, function (err) {
      // Warn the user with err.message
  });

  // Use client transaction factory to issue authorized API calls
  authz.http_transaction_factory({
      url: "http://mafreebox.freebox.fr/api/v1/whatever/"
  }).then(function(resp){
      console.log(resp);
  });

  // Or stack transaction factory in another client
  var client = new FreeboxOS.Client({
      http_transaction_factory: authz.http_transaction_factory
  });

  client.add("system", {flat: true});
  client.system.add("reboot", {flat: true});

  client.system.reboot.create().then(function(response) {
      console.log(response);
  });
 */

function Client(opts)
{
    this.opts = {};

    for (var k in Client.default_options)
        this.opts[k] = opts[k] !== undefined ? opts[k] : Client.default_options[k];

    this.__client = new FreeboxOS.Client({
        base_url: this.opts.base_url,
        http_transaction_factory: this.opts.http_transaction_factory,
        suffix: ""
    });

    if (opts.app_token)
        this.app_token = opts.app_token;

    this.__client.add("login");
    this.__client.login.add("authorize");
    this.__client.login.add("session");
    this.__client.login.add("logout");

    this.permissions = {};

    var self = this;

    // Enforce binding of 'this' on transaction()
    this.http_transaction_factory = function(opts) {
        return self._htf(opts);
    };
};

Client.default_options = {
    base_url: "http://mafreebox.freebox.fr/api/v3",
    http_transaction_factory: Http.Transaction.factory,
    app_id: Qt.application.domain || Qt.application.domain,
    app_name: Qt.application.name || Qt.application.name,
    app_version: Qt.application.version || Qt.application.version,
    device_name: Qt.platform.os || "Freebox Player"
};

Client.prototype.toString = function()
{
    return "<FreeboxOSAuth " + this.opts.app_id + "/" + this.app_token + ">";
};

Client.prototype.query = function()
{
    delete this.app_token;
    delete this.session_token;
    delete this.track_id;
    this.permissions = {};

    var self = this;

    return this.__client.login.authorize.create({
        app_id: this.opts.app_id,
        app_name: this.opts.app_name,
        app_version: this.opts.app_version,
        device_name: this.opts.device_name
    }).then(function (data) {
        self.track_id = data.track_id;
        self.app_token = data.app_token;
    });
};

Client.prototype.check = function()
{
    if (this.session_token)
        return Async.Deferred.resolved("granted");

    if (this.track_id === undefined)
        return Async.Deferred.rejected("No tracking ID");

    var self = this;

    return this.__client.login.authorize(this.track_id).read().then(function (data) {
        if (data.status == "granted") {
            delete self.track_id;
        }

        return data.status;
    });
};

Client.prototype._sendAuthenticatedTxn = function(txn, secondTry)
{
    var self = this;
    var start;

    if (self.session_token)
        start = Async.Deferred.resolved();
    else
        start = Async.Deferred.rejected("invalid_token");

    return start.then(function () {
        txn.headers.set("X-Fbx-App-Auth", self.session_token);
        return txn._post_auth_send();
    }).fail(function (err) {
        delete self.session_token;

        if (err.value == "invalid_token" && !secondTry) {
            var ch = err.raw && err.raw.result && err.raw.result.challenge;
            return self.sessionCreate(ch).then(function () {
                return self._sendAuthenticatedTxn(txn, true);
            });
        }

        return err;
    });
};

Client.prototype._htf = function(opts)
{
    var self = this;
    var txn = self.opts.http_transaction_factory(opts);

    if (txn.authenticated === false)
        return txn;

    txn._post_auth_send = txn.send;

    txn.send = function() {
        return self._sendAuthenticatedTxn(txn);
    };

    return txn;
};

Client.prototype.sessionCreate = function(challenge)
{
    var self = this;

    delete this.session_token;

    return Async.Deferred.resolved().then(function () {
        return challenge || self.__client.login.read().then(function (data) {
            return data.challenge;
        });
    }).then(function (ch) {
        return self.__client.login.session.create({
            app_id: self.opts.app_id,
            password: Crypto.HmacSha1.CryptoJS
                .HmacSHA1(ch, self.app_token)
                .toString(Crypto.HmacSha1.CryptoJS.enc.Hex)
        }).then(function(data) {
            self.session_token = data.session_token;
            self.challenge = data.challenge;
            self.permissions = data.permissions;
        });
    });
}

Client.prototype._register_poll = function(tq, timeout)
{
    var self = this;

    return tq.wait(1000).then(function() {
        return self.check().then(function (status) {
            switch (status) {
            case "granted":
                return "done";

            case "pending":
                if (timeout > 1000)
                    return self._register_poll(tq, timeout - 1000);
                // fallthrough
                return new Async.Deferred.Failure("timeout");

            default:
                return new Async.Deferred.Failure(status);
            }
        });
    });
}

Client.prototype.register = function(tq, timeout)
{
    var self = this;

    return self.query().then(function() {
        return self._register_poll(tq, timeout || 30000);
    });
}
