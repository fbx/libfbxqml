import QtQuick 2.0
import fbx.ui.base 1.0

FocusToggler {
    id: widget;

    /*** Public interface */
    property real value: 50;
    property real minimumValue: 0;
    property real maximumValue: 100;
    property real stepSize: (maximumValue - minimumValue) / 20;

    /*** Private */

    implicitWidth: 300
    implicitHeight: 40

    function setValue(v)
    {
        if (v < widget.minimumValue)
            v = widget.minimumValue;
        if (v > widget.maximumValue)
            v = widget.maximumValue;
        if (v != widget.value)
            widget.value = v;
    }

    ProgressBar {
        id: bar

        opacity: widget.enabled ? 1 : .4;

        anchors.centerIn: parent;
        height: 20;
        property int visibleHeight: widget.height / 4
        width: parent.width / scale - cursor.width / scale;
        scale: visibleHeight / height
        margin: 0;

        value: widget.value;
        smooth: false;
        border: true;
        minimumValue: widget.minimumValue;
        maximumValue: widget.maximumValue;
    }

    control: inner;

    Item {
        id: inner;

        anchors.fill: parent;
        anchors.leftMargin: cursor.width / 2;
        anchors.rightMargin: cursor.width / 2;

        property real ratio: ((widget.value - widget.minimumValue + .0) /
                              (widget.maximumValue - widget.minimumValue));

        Image {
            id: cursor;
            visible: widget.enabled
            source: "slider/" + (inner.activeFocus ? "cursor_focus.png" : "cursor_blur.png");

            anchors { topMargin: -9; leftMargin: -6; rightMargin: -6; bottomMargin: -6 }
            fillMode: Image.PreserveAspectFit;
            anchors.bottom: parent.verticalCenter;
            height: widget.height * 3 / 4;
            x: - width / 2 + inner.width * inner.ratio;
        }

        Keys.onPressed: {
            if (!widget.enabled) return;

            switch (event.key) {
            case Qt.Key_Left: {
                event.accepted = true;
                widget.setValue(widget.value - widget.stepSize);
                break;
            }

            case Qt.Key_Right: {
                event.accepted = true;
                widget.setValue(widget.value + widget.stepSize);
                break;
            }

            case Qt.Key_Back:
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Escape: {
                event.accepted = widget.leaveEditing();
                break;
            }
            }
        }

        MouseArea {
            anchors.fill: parent;
            enabled: widget.enabled;
            function updatePos() {
                widget.setValue(
                    widget.minimumValue
                     + (widget.maximumValue - widget.minimumValue) * mouseX / width);
            }

            onClicked: updatePos();
            onPositionChanged: if (mouse.buttons) updatePos();
        }
    }
}
