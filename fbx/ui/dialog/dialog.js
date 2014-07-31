.import QtQuick.Window 2.2 as QQW
.import fbx.async 1.0 as Async

function DialogState(owner, component, params, tries)
{
    Async.Deferred.Deferred.call(this, function(self) {
        self.cleanup();
    });

    this.owner = owner;
    this.component = component;
    this.params = params;
    this.tries = (tries || 0) + 1;

    var params = {};

    for (var k in this.params)
        params[k] = this.params[k];

    params.tries = this.tries;

    this.focusable = true;
    this.answered = false;

    var self = this;

    self.window = Qt.createQmlObject("import QtQuick.Window 2.2; Window{}", owner);

    new Async.Component.Incubator(self.component, self.window, params).then(function (obj) {
        self.object = obj;

        return new Async.Component.ComponentLoader(Qt.resolvedUrl("dialog_window.qml"))
    }).then(function (window_comp) {
        return new Async.Component.Incubator(window_comp, self.owner, {
            contentScale: self.scale(),
            contents: self.object
        });
    }).then(function (window) {
        self.window = window;
        self.object.buttonSelected.connect(self, DialogState.onButtonSelected);
    }, function(err) {
        self.reject(err);
    });
}

DialogState.prototype = new Async.Deferred.Deferred();
DialogState.prototype.constructor = DialogState;

DialogState.prototype.scale = function()
{
    /* Get owner scale from owner root application window */
    var root = this.owner;
    while (root.parent)
        root = root.parent;
    return root && root.scaler && Qt.binding(function () {return root.scaler.scale}) || 1;
}

DialogState.prototype.focus = function()
{
    this.object.focus = true;
};

DialogState.onButtonSelected = function(button)
{
    if (this.answered)
        return;

    this.answered = true;

    var data = {button: button, tries: this.tries};

    if (this.object.responseData) {
        try {
            data = this.object.responseData(data);
        } catch (e) {
            return this.cancel();
        }
    }

    var self = this;

    this.resolve(Async.Deferred.resolved(data).then(function (ret) {
        if (ret === "retry")
            return new DialogState(self.owner, self.component, self.params, self.tries);
        else if (ret && ret.button < 0)
            return new Async.Deferred.Failure("cancelled");
        else
            return ret;
    }).both(function (x) {
        self.cleanup();
        return x;
    }));
}

DialogState.prototype.cleanup = function()
{
    var focused;

    this.focusable = false;

    if (this.object) {
        this.object.buttonSelected.disconnect(this, DialogState.onButtonSelected);
        this.object.destroy();
        this.object = undefined;
    }

    if (this.window) {
        this.window.destroy();
        this.window = undefined;
    }
}

function create(owner, component, params, tries)
{
    return new DialogState(owner, component, params || {}, tries || 0);
}
