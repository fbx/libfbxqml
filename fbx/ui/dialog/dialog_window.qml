import QtQuick 2.2
import QtQuick.Window 2.2

Window {
    id: self
    color: "transparent"
    flags: Qt.Popup;
    visibility: Window.Windowed
    title: "dialog:"

    width: contents && (contents.width * contentScale) || 100
    height: contents && (contents.height * contentScale) || 100

    property real contentScale: 1
    property Item contents

    onHeightChanged: {
        if (height > 100) {
            contents.scale = Qt.binding(function () { return contentScale });
            contents.parent = contentItem;
            contents.anchors.centerIn = contentItem;
            contents.focus = true;
        }
    }
}
