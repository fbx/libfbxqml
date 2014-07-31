.pragma library

.import QtQuick 2.0 as QtQuick
.import "deferred.js" as Deferred

function Incubator(component, parent, args)
{
    Deferred.Deferred.call(this, function (self) {
        self._cleanup();
    });

    var self = this;

    parent = parent || null;
    args = args || {};
    this.incubator = component.incubateObject(parent, args, Qt.Asynchronous);
    this.incubator.onStatusChanged = function () {
        self.statusChanged();
    };

    if (this.incubator.status == QtQuick.Component.Ready)
        this.statusChanged();
};

Incubator.prototype = new Deferred.Deferred();
Incubator.prototype.constructor = Incubator;

Incubator.prototype._cleanup = function()
{
    this.incubator.onStatusChanged = null;
    this.incubator = null;
};

Incubator.prototype.connect = function()
{
}

Incubator.prototype.statusChanged = function()
{
    switch (this.incubator.status) {
    case QtQuick.Component.Ready:
        var o = this.incubator.object;
        this._cleanup();
        this.resolve(o);
        return;

    case QtQuick.Component.Error:
        this._cleanup();
        this.reject("failed");
        return;
    }
}

function ComponentLoader(url, component, factory)
{
    Deferred.Deferred.call(this, function (self) {
        self.diconnect();
    });

    this.factory = factory;
    this.url = url;
    if (component)
        this._component = component;
    else
        this._component = Qt.createComponent(
            url, QtQuick.Component.Asynchronous);
    this.connect();
    this.statusChanged();
};

ComponentLoader.prototype = new Deferred.Deferred();
ComponentLoader.prototype.constructor = ComponentLoader;

ComponentLoader.prototype.connect = function()
{
    this._component.statusChanged.connect(this, ComponentLoader.prototype.statusChanged);
}

ComponentLoader.prototype.disconnect = function()
{
    this._component.statusChanged.disconnect(this, ComponentLoader.prototype.statusChanged);
}

ComponentLoader.prototype.statusChanged = function()
{
    switch (this._component.status) {
    case QtQuick.Component.Ready:
        this.disconnect();
        if (this.factory)
            this.factory.touch(this);
        this.resolve(this._component);
        return;

    case QtQuick.Component.Error:
        this.disconnect();
        this.reject(this._component.errorString());
        return;
    }
}

function Factory(parent, lruSize)
{
    this.lruSize = lruSize || 3;
    this.lru = [];
    this.parent = parent;
}

Factory.prototype.get = function(url)
{
    for (var i = 0; i < this.lru.length; ++i) {
        var e = this.lru[i];

        if (e.url != url)
            continue;

        this.touch(e);
        return new ComponentLoader(url, e._component, this);
    }

    var e = new ComponentLoader(url, undefined, this);
    this.touch(e);
    return e;
};

Factory.prototype.cleanup = function()
{
    this.lru.splice(0, Math.max(0, this.lru.length - this.lruSize));
};

Factory.prototype.touch = function(elm)
{
    var i = this.lru.indexOf(elm);
    if (i >= 0)
        this.lru.splice(i, 1);

    this.lru.push(elm);
    this.cleanup();
};
