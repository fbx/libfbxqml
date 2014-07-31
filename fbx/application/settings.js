var dirty = false;
var values = {};
var connected = {};
var loading = false;
var saving = false;

function forEach(f)
{
    for (var k in self) {
        if (k == "objectName" || k.charAt(0) == "_")
            continue;

        if (!self[k + "Changed"])
            continue;

        var v = self[k];

        if (v && v.call !== undefined)
            continue;

        if (Qt.isQtObject(v))
            continue;

        f(k, v);
    }
}

function bind()
{
    forEach(function(k, v) {
        if (!connected[k]) {
            console.log("Setting", k, "connected")
            self[k+"Changed"].connect(valueChanged);
            connected[k] = true;
        }
    })
}

function load()
{
    if (saving)
        return;

    try {
        values = App && App.settings;
    } catch (e) {
        console.debug("Getting settings failed");
        return;
    }

    console.debug("Loading values", JSON.stringify(values));

    if (values === undefined)
        return;

    loading = true;

    forEach(function(k, v) {
        try {
            console.log(" ", k, values[k])
            if (values[k] !== undefined)
                self[k] = values[k];
        } catch (e) {
        }
    })

    loading = false;
    self.ready();
}

function valueChanged()
{
    console.log("Settings value changed", loading, dirty)

    if (loading)
        return;

    forEach(function (k, v) {
        console.log("Settings", k, values[k], v)

        if (values[k] === v)
            return;

        console.log("Settings", k, "changed")

        values[k] = v;
        dirty = true;
    })

    if (dirty)
        self._lazy.restart();
    else
        console.log("Settings not changed")
}

function save()
{
    if (!dirty)
        return;

    saving = true;
    try {
        console.log("Settings save", JSON.stringify(App.settings), JSON.stringify(values));
        App.settings = values;
    } catch (e) {}
    dirty = false;
    saving = false;
}
