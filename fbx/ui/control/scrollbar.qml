import QtQuick 2.0

Rectangle {
    id: widget

    opacity: autoHide ? 0 : 1
    color: "#80000000"
    radius: 2;

    property real widthRatio: 1
    property real heightRatio: 1
    property real xPosition: 0
    property real yPosition: 0

    property int animationDuration: 150

    property alias cursor: cursor;

    property bool autoHide: false;
    clip: true

    onAutoHideChanged: {
        if (autoHide) {
            autoHider.restart();
        } else {
            autoHider.stop();
            opacity = 1;
        }
    }

    Rectangle {
        id: cursor;
        radius: 2;

        color: "#80ffffff"

        x: parent.width * parent.xPosition
        y: parent.height * parent.yPosition
        width: parent.width * parent.widthRatio
        height: parent.height * parent.heightRatio

        Behavior on x {NumberAnimation{ duration: widget.animationDuration }}
        Behavior on y {NumberAnimation{ duration: widget.animationDuration }}

        onYChanged: widget.doAutoHide()
        onXChanged: widget.doAutoHide()
        onWidthChanged: widget.doAutoHide()
        onHeightChanged: widget.doAutoHide()
    }

    function doAutoHide()
    {
        if (!autoHide)
            return;
        autoHider.restart();
    }

    SequentialAnimation {
        id: autoHider
        PropertyAction { target: widget; property: "opacity"; value: 1 }
        PauseAnimation { duration: 500 }
        NumberAnimation { target: widget; property: "opacity"; to: 0; duration: 300 }
    }
}
