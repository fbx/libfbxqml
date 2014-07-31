import QtQuick 2.0

FocusScope {
    id: widget
    objectName: "fbx.ui.menu.Entry"
    enabled: false

    function view()
    {
        var w = widget;
        while (w && w.objectName != "fbx.ui.menu.View")
            w = w.parent;
        return w;
    }

    function pop()
    {
        return view().pop();
    }

    function close()
    {
        return view().close();
    }

    function push(x)
    {
        return view().push(x);
    }

    height: 40
    width: parent ? parent.width : 40
}
