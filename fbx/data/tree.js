.pragma library

function get_root(elem)
{
    while (elem.parent && elem.parent.children !== undefined)
        elem = elem.parent;

    return elem;
}

function has_focus_children(elem)
{
    var r = false;

    if (elem.children === undefined)
        return false;

    for (var i = 0; i < elem.children.length; ++i)
        r = r || elem.focus || has_focus_children(elem.children[i]);

    return r;
}

function find_child(elem, objectName)
{
    if (elem.objectName === objectName)
        return elem;

    if (elem.children === undefined)
        return;

    for (var i = 0; i < elem.children.length; ++i) {
        var e = find_child(elem.children[i], objectName);

        if (e)
            return e;
    }
}

function resource_find(elem, objectName)
{
    if (elem.objectName === objectName)
        return elem;

    if (elem.resources === undefined)
        return;

    for (var i = 0; i < elem.resources.length; ++i) {
        var e = find_child(elem.resources[i], objectName);

        if (e)
            return e;
    }
}
