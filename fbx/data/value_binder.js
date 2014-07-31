Qt.include("../lib/deferred.js");

var owner;
var propertyName;
var wip = null;

function bind(o, pn)
{
    if (owner && propertyName)
        owner[propertyName + "Changed"].disconnect(owner, save);

    owner = o;
    propertyName = pn;

    if (owner && propertyName) {
        owner[propertyName + "Changed"].connect(owner, save);
        load();
    }
}

function load()
{
     if (wip)
        return;

    wip = Deferred.resolved();

    wip.then(function () {
        return self.read();
    }).fail(function () {
        return self.defaultValue;
    }).then(function(value) {
        owner[propertyName] = value;
    }).both(function () {
        wip = null;
    });
}

function save()
{
    var owner = this;
    var value = owner[propertyName];

    if (wip)
        return;

    wip = Deferred.resolved();

    wip.then(function () {
        return self.write(value);
    }).both(function () {
        wip = null;
    });
}
