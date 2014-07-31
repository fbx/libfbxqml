.pragma library

function hasFocusChildren(elem)
{
    var r = false;

    try {
        for (var i = 0; i < elem.children.length; ++i)
            r = r || elem.focus || hasFocusChildren(elem.children[i]);
    } catch (e) {
    }

    return r;
}

function dump(elem, pfx, last)
{
    if (pfx === undefined)
        pfx = "";

    console.log(elem.focus ? "F" : "_",
                elem.activeFocus ? "A" : "_",
                pfx,
                last ? "`" : "+",
                elem,
                parseInt(elem.width) + "x" + parseInt(elem.height)
                + "+" + parseInt(elem.x) + "+" + parseInt(elem.y)
                + " " + parseInt(elem.anchors.leftMargin) + "+" + parseInt(elem.anchors.rightMargin));

    pfx = pfx + ((last || !pfx) ? "  " : " |");

    if (elem.children && elem.children.length && !hasFocusChildren(elem)) {
        console.log(" ", " ", pfx, "(no focusable children)");
    } else if (elem.children) {
        for (var i = 0; i < elem.children.length; ++i)
            dump(elem.children[i], pfx, i == elem.children.length - 1);
    }
}
