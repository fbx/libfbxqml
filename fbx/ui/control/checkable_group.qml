import QtQuick 2.0
import "checkable_group.js" as Script

QtObject {
    id: self

    property var value: null
    property bool canUnselect: false

    function __add(item)
    {
        Script.add(item);
    }

    onValueChanged: Script.valueChanged(value)

    Component.onCompleted: Script.completed()
}
