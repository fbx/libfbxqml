import QtQuick 2.0

Item {
    /*** Public API */
    property string status: "stop"

    implicitWidth: 30
    implicitHeight: 30

    /*** Private */

    Image {
        id: img
        smooth: true
        source: "player/" + parent.status + ".png"
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        transformOrigin: Item.Center
    }

    Timer {
        interval: 100
        repeat: true
        onTriggered: img.rotation += 45
        running: parent.status == "loading"
        onRunningChanged: if (!running) img.rotation = 0;
    }
}
