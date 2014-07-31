import QtQuick 2.0

Item {
    id: widget

    property bool checked: false
    property var value: null
    property var exclusiveGroup: null

    property bool inited: false

    function toggle() {
        checked = !checked;
    }

    onExclusiveGroupChanged: {
        if (exclusiveGroup && inited)
            exclusiveGroup.__add(widget);
    }

    Component.onDestruction: exclusiveGroup = null;

    Component.onCompleted: {
        inited = true;
        if (exclusiveGroup)
            exclusiveGroup.__add(widget);
    }
}
