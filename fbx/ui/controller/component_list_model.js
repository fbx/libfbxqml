.import fbx.async 1.0 as Async

var stack = [];
var destroyed = [];

var factory = new Async.Component.Factory(null, 3);

function Tracker(url, params, title)
{
    this.url = url;
    this.params = params || {};
    this.state = {};
    this.title = title;
    this.uid = Tracker.next_uid++;
}

Tracker.next_uid = 0;

Tracker.prototype.titleChanged = function()
{
    this.title = this.elem.title;
    updateTitles();
}

Tracker.prototype.attach = function()
{
    if (this.elem.titleChanged)
        this.elem.titleChanged.connect(this, this.titleChanged);
}

Tracker.prototype.deattach = function()
{
    if (this.elem.titleChanged)
        this.elem.titleChanged.disconnect(this, this.titleChanged);
}

Tracker.prototype.element = function()
{
    if (this.elem)
        return Async.Deferred.resolved(this.elem);

    var this_ = this;

    return factory.get(this_.url).then(function(component) {
        var params = {};

        for (var k in this_.params)
            params[k] = this_.params[k];

        for (var k in this_.state)
            params[k] = this_.state[k];

        return new Async.Component.Incubator(component, self.parent, params);
    }).then(function (element) {
        this_.elem = element;
        this_.attach();
        this_.title = element.title;
        updateTitles();
        return this_.elem;
    });
}

Tracker.prototype.property = function(name)
{
    if (this.elem)
        return this.elem[name];

    return this.state[name] || this.params[name];
}

Tracker.prototype.destroy = function()
{
    if (this.elem) {
        this.detach()
        this.elem.deleteLater();
        delete this.elem;
    }
}

function gc()
{
    for (var i = Math.max(0, stack.length - self.topCount); i < stack.length; ++i)
        stack[i].destroy();

    destroyed.forEach(function (e) {
        e.destroy();
    });

    destroyed = [];
}

function push(url, params, title)
{
    stack.push(new Tracker(absUrl(url), params, title));
}

function pop()
{
    destroyed.push(stack.pop());
}

function popTo(index)
{
    destroyed = destroyed.concat(stack.splice(index + 1, stack.length - index - 1));
}

function updateTitles()
{
    stack.forEach(function (e, i) {
        self.titleList.set(i, {title: e.title});
    });

    while (self.titleList.count > stack.length)
        self.titleList.remove(self.titleList.count - 1);
}

function commit()
{
    updateTitles();
    self.updated();
}

function tracker(index)
{
    if (index < 0)
        index += stack.length;

    return stack[index];
}

function element(index, parent)
{
    var elm = tracker(index);
    if (!elm)
        return Async.Deferred.rejected("No such index");

    return elm.element();
}

function getProperty(index, key)
{
    var elm = tracker(index);

    if (!elm)
        return;

    return elm.property(key);
}

function baseUrl()
{
    var url = self.baseUrl;

    if (stack.count)
        url = stack[stack.length - 1].url;

    var index = url.lastIndexOf("/");
    if (index >= 0)
        return url.substr(0, index + 1);
    else
        return url + "/";
}

function absUrl(url)
{
    var pos = url.search("://");

    if (pos < 5 && pos > 0)
        return url;

    if (url.charAt(0) == "/")
        return url;

    return baseUrl() + url;
}
