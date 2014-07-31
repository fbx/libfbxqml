import QtQuick 2.0

Item {
    id: widget

    /*** Public API */

    // visible
    // width, height

    // full rotation in ms
    property int period: 720;

    opacity: visible ? 1 : 0

    /*** Internal */

    implicitWidth: 116
    implicitHeight: 116

    Image {
        id: img;
        smooth: true;
        anchors.fill: parent;
        fillMode: Image.PreserveAspectFit;
        asynchronous: true

        source: {
            var s = widget.width < widget.height ? widget.width : widget.height;

            if (s <= 24) return "loading/24x24.png"
            if (s <= 54) return "loading/54x54.png"
            if (s <= 107) return "loading/107x107.png"
            return "loading/214x214.png"
        }

        Timer {
            interval: widget.period / 12;
            onTriggered: img.rotation += 360 / 12;
            repeat: true;
            running: widget.visible;
        }
    }

    Behavior on visible { NumberAnimation { duration: 800 } }
    Behavior on opacity { NumberAnimation { duration: 400 } }

    // Freebox specific extension, requires Qt patch
    property bool blackAndWhite: false

    onBlackAndWhiteChanged: {
        try {
            img.isColored = !blackAndWhite;
        } catch (e) {
        }
    }
}
