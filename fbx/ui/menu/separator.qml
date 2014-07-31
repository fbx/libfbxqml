import QtQuick 2.0

Entry {
    height: 12
    opacity: 0.5

    Rectangle {
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: - 5
        width: parent.width - 20
        height: 1
        anchors.verticalCenter: parent.verticalCenter
    }
}
