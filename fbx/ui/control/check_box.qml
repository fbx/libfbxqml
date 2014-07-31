import QtQuick 2.0
import fbx.ui.base 1.0

Checkable {
    id: widget;

    /*** Public interface */

    signal clicked();

    property string text: "";

    // Accepts user interaction
    enabled: true;

    property bool __bold: true

    /*** Private */

    property alias __show_bg: background.visible;

    // Default size
    implicitWidth: 135
    implicitHeight: 40

    // Internal
    property bool hovered: activeFocus || (mouse.containsMouse && widget.enabled);
    property bool pressed: false;

    onPressedChanged: {
        if (!pressed) {
            widget.toggle();
            widget.clicked()
        }
    }

    StandardAsset {
        id: background;
        anchors.fill: parent
        anchors.margins: 6
        background: widget.enabled ? (widget.activeFocus ? "CC0000" : "333333") : "666666";
        border: (widget.enabled && widget.hovered) ? "FF0000" : "";
        opacity: .6
    }

    Item {
        id: checkbox;

        anchors.top: parent.top;
        anchors.bottom: parent.bottom;
        anchors.left: parent.left;

        width: height

        Image {
            asynchronous: true
            smooth: true
            property string mode: widget.exclusiveGroup ? "radio" : "checkbox";
            source: mode + "/" + (widget.checked ? "checked" : "unchecked") + ".png";
            opacity: widget.enabled ? 1 : .5

            anchors.centerIn: parent;

            scale: (parent.height / 40) * (widget.pressed ? 1.2 : 1)
        }
    }

    Text {
        text: widget.text

        font.bold: __bold
        font.pixelSize: widget.height / 2
        smooth: true
        color: "white";
        elide: Text.ElideRight;
        horizontalAlignment: Text.AlignLeft;
        verticalAlignment: Text.AlignVCenter;

        anchors.left: checkbox.right;
        anchors.top: parent.top;
        anchors.bottom: parent.bottom;
        anchors.right: parent.right;
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: widget.enabled;
        hoverEnabled: widget.enabled;
        onPressed: widget.pressed = true;
        onReleased: widget.pressed = false;
    }

    Keys.onPressed: {
        if (!widget.enabled || event.isAutoRepeat)
            return;

        if (event.key == Qt.Key_Return) {
            event.accepted = true;
            widget.pressed = true;
            return;
        }
    }

    Keys.onReleased: {
        if (!widget.enabled)
            return;

        if (event.key == Qt.Key_Return) {
            event.accepted = true;
            widget.pressed = false;
            return;
        }
    }
}
