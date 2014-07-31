.pragma library

function isArray(x)
{
    return Object.prototype.toString.call(x) === '[object Array]';
}

function camel(x)
{
    return x.replace(/(_[a-zA-Z])/g, function(m) {
        return m.charAt(1).toUpperCase();
    });
};

function flatten(o)
{
    var ret = {};

    for (var k in o) {
        if (typeof o[k] == "object" && !isArray(o[k])) {
            var o2 = flatten(o[k]);
            for (var k2 in o2)
                ret[camel(k+"_"+k2)] = o2[k2];
        } else {
            ret[camel(k)] = o[k];
        }
    }

    return ret;
}

function string_array_flatten(o, prefix, l)
{
    l.forEach(function(x) {
        o[camel(prefix+"_"+x)] = true;
    });
}
