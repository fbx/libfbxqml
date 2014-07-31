.pragma library

var Xml = {};

Xml.escape = function(t)
{
    if (!t) return t
    return t.replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
};

Xml.unescape = function(t)
{
    var lookup = {
        lt: "<",
        gt: ">",
        quot: '"',
        apos: "'",
        amp: "&"
    };

    if (!t) return t
    return t.replace(/&([a-z]+);/g, function (whole, match) {
        return lookup[match] || whole;
    });
};

Xml.Node = function()
{
    if (arguments.length < 1)
        throw "Nodes must have a name";

    this.name = arguments[0];
    this.attrs = {};
    this.children = [];
    var base = 1;

    if (arguments.length > 1 && typeof arguments[1] === "object" && !(arguments[1] instanceof Xml.Node)) {
        for (var k in arguments[1])
            this.attrs[k] = arguments[1][k];
        base = 2;
    }

    for (var i = base; i < arguments.length; ++i)
        this.push(arguments[i]);
};

Xml.Node.prototype.toString = function ()
{
    var r = "<" + this.name;
    for (var k in this.attrs)
        r += " " + k + "=\"" + Xml.escape(this.attrs[k].toString()) + "\"";
    r += ">"
    for (var i = 0; i < this.children.length; ++i) {
        var o = this.children[i];

        if (o instanceof Xml.Node)
            r += o.toString();
        else
            r += Xml.escape(o);
    }
    return r + "</" + this.name + ">";
};

Xml.Node.prototype.get = function (nodeName, attrs)
{
    for (var i = 0; i < this.children.length; ++i) {
        var node = this.children[i];

        if (node.name != nodeName)
            continue;

        var match = true;

        for (var k in attrs)
            match &= node.attrs[k] === attrs[k];

        if (!match)
            continue;

        return node;
    }

    return null;
};

Xml.Node.prototype.push = function (child)
{
    this.children.push(child);
    return this;
};

Xml.Node.factory = function()
{
    var node = new Xml.Node("foo");

    Xml.Node.apply(node, Array.prototype.slice.call(arguments));

    return node;
};

Xml.Node.fromDom = function (node)
{
    switch (node.nodeType) {
    case 3: // Text node
        return node.nodeValue.toString();

    case 1: {// Element node
        var attrs = {};

        for (var i = 0; i < node.attributes.length; ++i)
            attrs[node.attributes[i].name] = node.attributes[i].value;

        var ret = new Xml.Node(node.nodeName, attrs);

        for (var n = node.firstChild; n; n = n.nextSibling) {
            var c = Xml.Node.fromDom(n);
            if (c)
                ret.push(c);
        }

        return ret;
    }
    }
};

Xml.Node.fromString = function (text)
{
    var stack = [];
    var poped, node;

    var iter = text.split(/(<[^>]+>)/);
    for (var i = 0; i < iter.length; ++i) {
        var item = iter[i];

        if (item.charAt(0) == "<") {
            item = item.slice(1, -1);

            switch (item.charAt(0)) {
            case "/": {
                var nodeName = item.slice(1).trim();

                if (!node || node.name != nodeName)
                    throw "Malformed document";
                poped = stack.pop();
                node = stack[stack.length - 1];
                break;
            }

            case "?":
                break;

            case "!":
                break;

            default: {
                var self_closing = !!item.match(/\/$/);
                if (self_closing)
                    item = item.slice(0, -1).trim();

                var nodeName = item.match(/^([a-z0-9_-]+)/i)[1];

                var attrs = item.split(/[	 ]+/g);
                var ad = {};

                for (var j = 1; j < attrs.length; ++j) {
                    var kv = attrs[j].match(/([a-z-]+)(="[^"]*"|='[^']*')?/i);
                    ad[kv[1]] = kv[2].slice(2, -1);
                }

                var n = new Xml.Node(nodeName, ad);

                if (node)
                    node.push(n);

                if (!self_closing) {
                    stack.push(n);
                    node = n;
                }
                break;
            }
            }
        } else {
            item = item.trim();

            if (item.length == 0 && (!node || node.children.length == 0))
                continue;

            if (!node)
                throw "Malformed document";

            var text = Xml.unescape(item);
            node.push(text);
        }
    }

    return poped;
};
