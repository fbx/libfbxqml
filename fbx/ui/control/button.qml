import QtQuick 2.0
import fbx.ui.base 1.0

FocusScope {
    id: widget;

    /*** Public interface */

    signal clicked();

    property string text: "OK";

    // Accepts user interaction
    enabled: true;

    /*** Private */

    property bool __glow: true;
    property bool __bold: true;
    property alias __backgroundShown: background.visible;

    // Default size
    implicitWidth: fitText ? 135 : (label.paintedWidth + 32)
    implicitHeight: 40

    property bool fitText: true;
    property int fontSize: height / 2

    // Internal
    property bool hovered: activeFocus || (mouse.containsMouse && widget.enabled);
    property bool pressed: false;
    property bool __ignore: false;

    onPressedChanged: {
        if (!pressed && !__ignore) {
            widget.clicked()
        }
        __ignore = false;
    }

    onActiveFocusChanged: {
        __ignore = true;
        pressed = false;
    }

    default property var buttonContent: label

    children: [
        StandardAsset {
            id: background;
            anchors.fill: parent
            anchors.margins: (pressed || mouse.containsMouse) ? 4 : 6;
            background: widget.enabled ? (widget.activeFocus ? "CC0000" : "333333") : "666666";
            degrade: widget.enabled && widget.__glow;
            reflet: widget.__glow;
            border: (widget.enabled && widget.hovered) ? "FF0000" : "";
        },
        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: widget.enabled;
            hoverEnabled: widget.enabled;
            onPressed: widget.pressed = true;
            onReleased: widget.pressed = false;
        },
        Item {
            id: container
            anchors.fill: parent
            children: buttonContent
        }
    ]

    data: [
        Text {
            id: label
            text: widget.text
            font.bold: widget.__bold
            font.pixelSize: widget.fontSize
            smooth: true
            color: "white";
            anchors.centerIn: container;
            scale: fitText ? Math.min(1, (widget.width - 20) / paintedWidth) : 1
        }
    ]

    Keys.onPressed: {
        if (!widget.enabled)
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
