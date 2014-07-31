import QtQuick 2.0
import "value_binder.js" as Script

Item {
    id: self

    property bool valid: false
    property var defaultValue

    property var owner: parent
    property string propertyName

    onOwnerChanged: Script.bind(owner, propertyName);
    onPropertyNameChanged: Script.bind(owner, propertyName);
    Component.onCompleted: Script.bind(owner, propertyName);

    function write(value)
    {
        return Script.Deferred.rejected();
    }

    function read()
    {
        return Script.Deferred.rejected();
    }
}
