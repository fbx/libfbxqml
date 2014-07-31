import QtQuick 2.0

FocusScope {
    id: widget;

    /*** Public interface */

    signal clicked();

    // Accepts user interaction
    enabled: true;

    // Default size
    implicitWidth: 135
    implicitHeight: 40

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

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: widget.enabled
        hoverEnabled: widget.enabled
        onPressed: widget.pressed = true
        onReleased: widget.pressed = false
    }

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
