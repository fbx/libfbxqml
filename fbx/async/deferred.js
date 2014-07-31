.pragma library

// Based on MIT code by HeavyLifters
// https://github.com/heavylifters/deferred-js

function Failure(v) {
    this.value = v
}

Failure.prototype.toString = function()
{
    return "<" + this.constructor.name + " " + this.value + ">";
};

Failure.prototype.__is_deferred_failure = true;

function is_failure(x)
{
    return x && x.__is_deferred_failure;
};

var Deferred_uid = 0;

function Deferred(canceller) {
    this.called = false
    this.running = false
    this.result = null
    this.pauseCount = 0
    this.callbacks = []
    this.progressCallbacks = []
    this.verbose = false
    this._canceller = canceller
    this._uid = Deferred_uid++;

    // If this Deferred is cancelled and the creator of this Deferred
    // didn't cancel it, then they may not know about the cancellation and
    // try to resolve or reject it as well. This flag causes the
    // "already called" error that resolve() or reject() normally throws
    // to be suppressed once.
    this._suppressAlreadyCalled = false
}

Deferred.prototype.__is_deferred = true;
Deferred.prototype._debug = false;

function is_deferred(x)
{
    return x && x.__is_deferred;
};

function resolved(r)
{
    var d = new Deferred();
    d.resolve(r);
    return d;
};

function rejected(r)
{
    var d = new Deferred();
    d.reject(r);
    return d;
};

Deferred._continue = function(d, newResult) {
    d.result = newResult
    d.log("unpausing");
    d.unpause()
    return d.result
}

Deferred._nest = function(outer) {
    outer.log("nesting");
    outer.result.both((function (o) {
        return function(newResult) {
            Deferred._continue(o, newResult);
            return newResult;
        };
    })(outer));
}

Deferred._startRun = function(d, result) {
    d.log("startrun("+result+")");
    if (d.called) {
        if (d._suppressAlreadyCalled) {
            d._suppressAlreadyCalled = false
            return
        }
        throw new Error("Already resolved Deferred: " + d)
    }
    d.called = true
    d.result = result
    if (is_deferred(d.result)) {
        d.pause()
        Deferred._nest(d)
        return
    }
    Deferred._run(d)
}

Deferred._run = function(d) {
    if (d.running) return
    if (d.pauseCount > 0) return
    while (d.callbacks.length > 0) {
        d.log("run()", d.callbacks.length, "callbacks left");
        var link, status, fn
        link = d.callbacks.shift()
        status = (is_failure(d.result)) ? 'errback' : 'callback'
        fn = link[status]
        if (typeof fn !== 'function') continue
        d.running = true
        try {
            d.log("\n->>>>", fn, status, d.result);
            d.result = fn(d.result)
            d.log("\n<<<<-", d.result);
        } catch (e) {
            d.log("\n<<**-", e);

            console.log('\x1b[31mUncaugth error in ' + status + "\x1b[0m")
            console.log('\x1b[31mIn file ' + e.fileName + ":" + e.lineNumber + "\x1b[0m")
            console.log('\x1b[31m     ' + e.message + "\x1b[0m")

            var f = new Failure(e)
            f.source = f.source || status
            d.result = f
        }
        d.running = false
        if (is_deferred(d.result)) {
            d.log("paused, waiting for", d.result);
            d.pause()
            Deferred._nest(d)
            return
        }
    }
}

Deferred.prototype.cancel = function() {
    if (!this.called) {
        if (typeof this._canceller === 'function') {
            this._canceller(this)
        } else {
            this._suppressAlreadyCalled = true
        }
        if (!this.called) {
            this.reject('cancelled')
        }
    } else if (is_deferred(this.result)) {
        this.result.cancel()
    }
}

Deferred.prototype.progress = function(data) {
    for (var i = 0; i < this.progressCallbacks.length; ++i) {
        try {
            this.progressCallbacks[i](data);
        } catch (e) {}
    }
};

Deferred.prototype.onProgress = function(callback) {
    if (callback)
        this.progressCallbacks.push(callback)
    return this
}

Deferred.prototype.then = function(callback, errback, progressback) {
    this.callbacks.push({callback: callback, errback: errback})
    this.log("then(", callback && "fn", errback && "fn", "), now ", this.callbacks.length, "callbacks");
    this.onProgress(progressback);
    if (this.called) Deferred._run(this)
    return this
}

Deferred.prototype.fail = function(errback) {
    return this.then(undefined, errback);
}

Deferred.prototype.both = function(callback) {
    return this.then(callback, callback)
}

Deferred.prototype.resolve = function(result) {
    this.log("resolve("+result+")");
    Deferred._startRun(this, result)
    return this
}

Deferred.prototype.reject = function(err) {
    this.log("reject("+err+")");
    if (!is_failure(err)) {
        err = new Failure(err)
    }
    Deferred._startRun(this, err)
    return this
}

Deferred.prototype.log = function()
{
    if (!this._debug)
        return;

    var args = [];
    for (var i = 0; i < arguments.length; ++i)
        args.push("" + arguments[i]);

    console.log(this, args.join(" "))
};

Deferred.prototype.debug = function(name)
{
    this._debug = name;
    this.log("debug start");
    return this
}

Deferred.prototype.toString = function()
{
    return "<"+this._uid+" "+this.constructor.name+" "+this._debug+">";
};

Deferred.prototype.pause = function() {
    this.pauseCount += 1
    return this
}

Deferred.prototype.unpause = function() {
    this.pauseCount -= 1
    if (this.pauseCount <= 0 && this.called) {
        Deferred._run(this)
    }
    return this
}

// For debugging
Deferred.prototype.inspect = function(extra) {
    var cb = (function (_this, _extra) {
        return function(v) {
            _this.log(_extra);
            return v;
        };
    })(this, extra);
    return this.both(cb);
}

/// A couple of sugary methods

Deferred.prototype.thenReturn = function(result) {
    return this.then(function(_) { return result })
}

Deferred.prototype.thenCall = function(f) {
    return this.then(function(result) {
        f(result)
        return result
    })
}

Deferred.prototype.failReturn = function(result) {
    return this.fail(function(_) { return result })
}

Deferred.prototype.failCall = function(f) {
    return this.fail(function(result) {
        f(result)
        return result
    })
}


function List(ds, opts) {
    opts = opts || {}
    Deferred.call(this)
    this._deferreds = ds
    this._finished = 0
    this._length = ds.length
    this._results = []
    this._fireOnFirstResult = opts.fireOnFirstResult
    this._fireOnFirstError = opts.fireOnFirstError
    this._consumeErrors = opts.consumeErrors
    this._cancelDeferredsWhenCancelled = opts.cancelDeferredsWhenCancelled

    if (this._length === 0 && !this._fireOnFirstResult) {
        this.resolve(this._results)
    }

    for (var i = 0, n = this._length; i < n; ++i) {
          ds[i].both(List._callback(this, i))
    }
}

List.prototype = new Deferred()

List.prototype.constructor = List

List.factory = function(list)
{
    return new List(list);
};

// Concatenate a list of list of deferreds yielding lists as one list
// of results
List.concatenated = function(lod, opts)
{
    return new List(lod, opts).then(function (lol) {
        var ret = [];

        for (var i = 0; i < lol.length; ++i)
            ret = ret.concat(lol[i]);

        return ret;
    });
};

List.prototype.cancelDeferredsWhenCancelled = function() {
    this._cancelDeferredsWhenCancelled = true
}

List.prototype.cancel = function() {
    Deferred.prototype.cancel.call(this)
    if (this._cancelDeferredsWhenCancelled) {
        for (var i = 0; i < this._length; ++i) {
            this._deferreds[i].cancel()
        }
    }
}

List._callback = function(d, i) {
    return function(result) {
        var isErr = is_failure(result)
          , myResult = (isErr && d._consumeErrors) ? null : result
        // Support nesting
        if (is_deferred(result)) {
            result.both(List._callback(d, i))
            return
        }
        d._results[i] = myResult
        d._finished += 1

        d.log("Results:", d._finished, "/", d._length, isErr ? "error" : "result");

        if (!d.called) {
            if (d._fireOnFirstResult && !isErr) {
                d.log("Resolve first");
                d.resolve(result)
            } else if (d._fireOnFirstError && isErr) {
                d.log("Reject first");
                d.reject(result)
            } else if (d._finished === d._length) {
                d.log("done");
                d.resolve(d._results)
            }
        }
        return myResult
    }
}
