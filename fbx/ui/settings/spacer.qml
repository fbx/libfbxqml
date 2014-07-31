import QtQuick 2.0

Item {
    id: widget
    property string info: ""
    property bool enabled: false
    implicitHeight: childrenRect.height ? childrenRect.height : 30
    width: parent ? parent.width : 40
}
