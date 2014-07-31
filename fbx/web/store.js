.import fbx.async 1.0 as Async
.import "http.js" as Http

function Item(parent, data)
{
    if (parent === undefined)
        return;

    this.parent = parent;
    this.type = data.item_type;
    this.name = data.name;
    this.weight = data.weight || 1;
    this.priv = data.priv;
}

Item.prototype.path = function()
{
    if (this._path === undefined)
        this._path = this.parent.path() + "/" + encodeURIComponent(this.name);

    return this._path;
};

Item.prototype.toString = function()
{
    return "<Item " + this.path() + ">";
};

Item.prototype.model = function()
{
    return {
        name: this.name,
        type: this.type
    };
};

Item.prototype.client = function ()
{
    return this.parent.client();
};

function Directory(parent, data)
{
    if (parent === undefined)
        return;

    Item.call(this, parent, data);
    this.length = data.directory_content_count;
    this.item_count = data.directory_content_item_count;
    this.subdir_count = data.directory_content_subdir_count;
    this.type = "directory";
    this.sorting = data.preferred_item_sort_type;

    if (data.directory_content)
        this.handle_content(data.directory_content);
    else
        this._content_url = data.directory_content_url;
}

Directory.prototype = new Item();
Directory.prototype.constructor = Directory;

Directory.prototype.model = function()
{
    var r = Item.prototype.model.call(this);

    r.length = this.length;
    r.item_count = this.item_count;
    r.subdir_count = this.subdir_count;

    return r;
};

Directory.prototype.contents = function()
{
    if (this._content !== undefined)
        return Async.Deferred.resolved(this._content.slice(0));

    var self = this;
    var client = this.client();

    return client.dataRead(this._content_url).then(function(data) {
        self.handle_content(data);

        return self._content.slice(0);
    });
};

Directory.prototype.handle_content = function(data)
{
    var client = this.client();

    var contents = [];

    for (var i = 0; i < data.content.length; i++)
        contents.push(client.create_object(this, data.content[i]));

    this._content = contents;
};

Directory.prototype.getByIndex = function(index)
{
    var self = this;

    return this.contents().then(function (contents) {
        return contents[index];
    })
};

Directory.prototype.getByName = function(name)
{
    var self = this;

    if (name == "") {
        return Async.Deferred.resolved(this);
    }

    return this.contents().then(function (contents) {
        for (var i = 0; i < contents.length; ++i) {
            if (contents[i].name == name)
                return contents[i];
        }
    });
};

Directory.prototype.list = function(sorting)
{
    switch (sorting || this.sorting) {
    case "weighted_random":
        return this.contents().then(function (contents) {
            var weights = {};

            for (var i = 0; i < contents.length; ++i)
                weights[contents[i].name] = Math.random() * contents[i].weight;

            contents.sort(function (a, b) {
                return weight[a.name] - weight[b.name];
            });

            return contents;
        });

    case "alpha":
        return this.contents().then(function (contents) {
            contents.sort(function (a, b) {
                return a.name < b.name ? -1 : 1;
            });

            return contents;
        });

    default:
        return this.contents();
    }
};

Directory.prototype.walk = function(path)
{
    var parts = path.match(/([^\/]*)\/?(.*)/);

    var here = decodeURIComponent(parts[1]);
    var others = parts[2];

    var self = this;

    return this.getByName(here).then(function (node) {
        if (others.length)
            return node.walk(others);
        return node;
    });
};

Directory.prototype.toString = function()
{
    return "<Directory "
        + this.path()
        + ", "
        + this.length
        + (this._content !== undefined ? " fetched" : " tbd")
        + ">";
};

Directory.prototype.listModel = function()
{
    var self = this;

    return this.list().then(function (list) {
        var r = [];

        for (var i = 0; i < list.length; ++i)
            r.push(list[i].model());

        return r;
    });
}

function Client(opts)
{
    if (!opts)
        return;

    this.opts = {};
    this.fetching = {};

    for (var k in Client.defaults)
        this.opts[k] = opts[k] !== undefined ? opts[k] : Client.defaults[k];

    Directory.call(this, null, {
        weight: 1,
        directory_content_url: this.opts.root,
        name: this.opts.root_name,
        type: "directory"
    });
}

Client.prototype = new Directory();
Client.prototype.constructor = Client;

Client.defaults = {
    http_transaction_factory: Http.Transaction.factory,
    root: "root.json",
    base_url: undefined,
    suffix: "",
    root_name: "Root",
    imgs_url: undefined
};

Client.prototype._reset = function()
{
    delete this._content;

    try {
        this.reset();
    } catch (e) {}
};

Client.prototype.client = function ()
{
    return this;
};

Client.prototype.path = function ()
{
    return "";
};

Client.prototype.dataRead = function(id)
{
    if (id === undefined)
        id = this.opts.root;

    var self = this;

    var f = this.fetching[id];
    var isnew = false;

    if (!f) {
        f = this.opts.http_transaction_factory({
            url: this.opts.base_url + id + this.opts.suffix
        }).send().then(function (rsp) {
            if (rsp.isError()) {
                self._reset();
                return rsp;
            }
            var jrsp = rsp.jsonParse();
            if (jrsp.isError())
                return jrsp;
            return jrsp.data;
        });;
        this.fetching[id] = f;
        isnew = true;
    }

    var ret = Async.Deferred.resolved(f);

    if (isnew)
        f.both(function (x) {
            delete self.fetching[id];
            return x;
        });

    return ret;
};

Client.prototype.create_object = function(parent, data)
{
    var func = this["create_" + data.type];

    return func.call(this, parent, data);
};

Client.prototype.create_directory = function(parent, data)
{
    return new Directory(parent, data);
};

Client.prototype.create_item = function(parent, data)
{
    return new Item(parent, data);
};

Client.prototype.toString = function()
{
    return "<Client " + this.opts.base_url + ">";
};

Client.prototype.imagePick = function(imgInfo, optimalSize)
{
    if (!imgInfo || !imgInfo.images || !imgInfo.images.length)
        return "";

    var imgRatio = imgInfo.ratio[0] / imgInfo.ratio[1];
    var optimalRatio = optimalSize.ratio
        || ((optimalSize.width && optimalSize.height) ? optimalSize.width / optimalSize.height : 1);
    var optimalWidth = optimalSize.width || (optimalHeight * optimalRatio);
    var optimalHeight = optimalSize.height || (optimalWidth / optimalRatio);

    var ret = [];

    for (var i = 0; i < imgInfo.images.length; ++i) {
        var img = imgInfo.images[i];

        var o = {
            url: this.opts.imgs_url + img.url,
            width: img.width || (img.height * imgRatio),
            height: img.height || (img.width / imgRatio),
            ratio: (img.width && img.height) ? img.width / img.height : imgRatio
        };

        o.ratioGap = optimalRatio - o.ratio;
        o.widthGap = optimalWidth - o.width;
        o.heightGap = optimalHeight - o.height;

        ret.push(o);
    }

    ret.sort(function (a, b) {
        if (a.ratioGap != b.ratioGap)
            return a.ratioGap < b.ratioGap ? -1 : 1;
        if (a.widthGap != b.widthGap)
            return a.widthGap < b.widthGap ? -1 : 1;
        if (a.heightGap != b.heightGap)
            return a.heightGap < b.heightGap ? -1 : 1;
        return 0;
    });

    return ret[0].url;
};
